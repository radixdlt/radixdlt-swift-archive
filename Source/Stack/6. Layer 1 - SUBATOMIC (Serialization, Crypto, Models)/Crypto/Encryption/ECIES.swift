//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import CryptoKit

// swiftlint:disable all

/// Encrypt and Decrypt data using ECIES (Elliptic Curve Integrated Encryption Scheme) (subset of DHIES): https://en.wikipedia.org/wiki/Integrated_Encryption_Scheme
public final class ECIES {
    private let crypt: Crypt
    private let sha512TwiceHasher: SHA512TwiceHashing
    public init(
        crypt: Crypt = .init(),
        sha512TwiceHasher: SHA512TwiceHashing = SHA512TwiceHasher()
    ) {
        self.crypt = crypt
        self.sha512TwiceHasher = sha512TwiceHasher
    }
}

// MARK: Constants
public extension ECIES {
    var byteCountInitializationVector: Int { return 16 }
    var byteCountHashH: Int { return 64 }
    var byteCountMac: Int { return 32 }
    var byteCountCipherTextLength: Int { return MemoryLayout<UInt32>.size }
}

public extension ECIES {
    /// Calculates a 32 byte MAC with HMACSHA256
    func calculateMAC(salt: DataConvertible, initializationVector iv: DataConvertible, ephemeralPublicKey: PublicKey, cipherText: DataConvertible) throws -> Data {
        let message = iv + ephemeralPublicKey.asData + cipherText
        
        let key: SymmetricKey = .init(data: salt.bytes)
        
        let authentication = HMAC<SHA256>.authenticationCode(for: message.bytes, using: key)
        return Data(authentication)
    }
    
    func encrypt(data dataConvertible: DataConvertible, using publicKeyOwner: PublicKeyOwner) throws -> Data {
        let data = dataConvertible.asData
        // 0. Here follows ECEIS algorithm (steps copied from Radix DLT Java library)
        // 1. The destination is this publicKey
        let point: EllipticCurvePoint
        do {
            point = try EllipticCurvePoint.decodePointFromPublicKey(publicKeyOwner.publicKey)
        } catch let decodePublicKeyError as EllipticCurvePoint.Error {
            throw DecryptionError.failedToDecodePublicKeyPoint(error: decodePublicKeyError)
        } catch { unexpectedlyMissedToCatch(error: error) }
        
        
        // 2. Generate 16 random bytes using a secure random number generator. Call them IV
        // swiftlint:disable:next identifier_name
        let iv = try securelyGenerateBytes(count: byteCountInitializationVector)
        
        // 3. Generate a new ephemeral EC key pair
        let ephemeralKeyPair = KeyPair()
        
        // 4. Do an EC point multiply with this.getPublicKey() and ephemeral private key. This gives you a point M.
        let pointM = point * ephemeralKeyPair.privateKey
        
        // 5. Use the X component of point M and calculate the SHA512 hash H.
        let hashH = RadixHash(unhashedData: pointM.x.asData, hashedBy: sha512TwiceHasher).asData
        assert(hashH.length == byteCountHashH)
        
        // 6. The first 32 bytes of H are called key_e and the last 32 bytes are called key_m.
        let keyDataE = hashH.prefix(byteCountHashH/2)
        let keyDataM = hashH.suffix(byteCountHashH/2)
        
        // 7. Pad the input text to a multiple of 16 bytes, in accordance to PKCS7.
        // 8. Encrypt the data with AES-256-CBC, using IV as initialization vector, `keyDataE` as encryption key and the padded input text as payload.
        let cipherText = try crypt.encrypt(initializationVector: iv, data: data, keyE: keyDataE)
        
        // 9. Calculate a 32 byte MAC, using keyDataM as salt and `IV + ephemeral.pub + cipherText` as data
        let macData = try calculateMAC(
            salt: keyDataM,
            initializationVector: iv,
            ephemeralPublicKey: ephemeralKeyPair.publicKey,
            cipherText: cipherText
        )
        assert(macData.length == byteCountMac)
        
        // 10. Concatenate: IV | ephemeral.pub.length | ephemeral.pub | cipherText.length | cipherText | MAC
        func encodeCipherTextLength() -> Data {
            let cipherTextLength = UInt32(cipherText.length)
            let bigEndianInt32Bytes = CFSwapInt32HostToBig(cipherTextLength)
            return bigEndianInt32Bytes.asData
        }
        let ephermalPublicKeyLength = Byte(ephemeralKeyPair.publicKey.length).asData
        let ephermalPublicKey = ephemeralKeyPair.publicKey.asData
        let cipherTextLength = encodeCipherTextLength()
        
        let encrypted: Data = [
            iv,
            ephermalPublicKeyLength,
            ephermalPublicKey,
            cipherTextLength,
            cipherText,
            macData
        ].reduce(Data(), +)
        
        return encrypted
    }

    func decrypt(data dataConvertible: DataConvertible, using signing: Signing) throws -> Data {
        var encrypted = dataConvertible.asData
        let privateKey = signing.privateKey
        
        func parse(byteCount: Int) -> Data {
            let dropped = encrypted.droppedFirst(byteCount)
            return dropped
        }
     
        // 1. Read the IV
        let iv: Data = parse(byteCount: byteCountInitializationVector)
        
        // 2. Read the ephemeral public key
        let publicKeyLengthData: Data = parse(byteCount: 1)
        guard let publicKeyLength = Int(publicKeyLengthData.hex, radix: 16) else {
            throw DecryptionError.failedToConvertPublicKeyLengthDataToInteger
        }
        let publicKeyData = parse(byteCount: publicKeyLength)
        let ephemeralPublicKey = try PublicKey(data: publicKeyData)
        let ephemeralPublicKeyPoint: EllipticCurvePoint
        do {
            ephemeralPublicKeyPoint = try EllipticCurvePoint.decodePointFromPublicKey(ephemeralPublicKey)
        } catch let decodePublicKeyError as EllipticCurvePoint.Error {
            throw DecryptionError.failedToDecodePublicKeyPoint(error: decodePublicKeyError)
        } catch { incorrectImplementation("unhandled error: \(error)") }
        
        // 3. Do an EC point multiply with this.getPrivateKey() and ephemeral public key. This gives you a point M.
        let pointM = ephemeralPublicKeyPoint * privateKey
        
        // 4. Use the X component of point M and calculate the SHA512 hash H.
        let hashH = RadixHash(unhashedData: pointM.x.asData, hashedBy: sha512TwiceHasher).asData
        assert(hashH.length == byteCountHashH)
        
        // 5. The first 32 bytes of H are called key_e and the last 32 bytes are called key_m.
        let keyDataE = hashH.prefix(byteCountHashH/2)
        let keyDataM = hashH.suffix(byteCountHashH/2)
        
        // 6. Read cipherText data
        let cipherTextLengthDataBigEndian: Data = parse(byteCount: byteCountCipherTextLength)
        let cipherTextLengthMaybeIncorrectEndian = try UInt32(data: cipherTextLengthDataBigEndian)
        let cipherTextLength = CFSwapInt32HostToBig(cipherTextLengthMaybeIncorrectEndian)
  
        let cipherText = parse(byteCount: Int(cipherTextLength))
     
        // 6. Read MAC
        let mac = parse(byteCount: byteCountMac)

        // 7. Compare MAC with MAC'. If not equal, decryption will fail.
        let calculatedMac = try calculateMAC(salt: keyDataM, initializationVector: iv, ephemeralPublicKey: ephemeralPublicKey, cipherText: cipherText)
        
        guard calculatedMac == mac else {
            throw DecryptionError.macMismatch(expected: mac, butGot: calculatedMac)
        }
        
        // 8. Decrypt the cipher text with AES-256-CBC, using IV as initialization vector, key_e as decryption key and the cipher text as payload. The output is the padded input text.
        let decrypted = try crypt.decrypt(initializationVector: iv, data: cipherText, keyE: keyDataE)
        
        return decrypted
    }
}


extension Data {
    /// Mutates current data and returns the first `byteCount` bytes that was dropped
    mutating func droppedFirst(_ byteCount: Int) -> Data {
        let dropped = prefix(byteCount)
        self = dropFirst(byteCount)
        return Data(dropped)
    }
}

// swiftlint:enable all
