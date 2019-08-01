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
import CryptoSwift

// swiftlint:disable all

/// Encrypt and Decrypt data using ECIES (Elliptic Curve Integrated Encryption Scheme) (subset of DHIES): https://en.wikipedia.org/wiki/Integrated_Encryption_Scheme
public final class ECIES {}
public extension ECIES {
    /// Calculates a 32 byte MAC with HMACSHA256
    static func calculateMAC(salt: DataConvertible, initializationVector iv: DataConvertible, ephemeralPublicKey: PublicKey, cipherText: DataConvertible) throws -> Data {
        let message = iv + ephemeralPublicKey.asData + cipherText
        let macBytes = try HMAC(key: salt.bytes, variant: .sha256).authenticate(message.bytes)
        return macBytes.asData
    }
    
    static let byteCountInitializationVector = 16
    static let byteCountHashH = 64
    static let byteCountMac = 32
    static let byteCountCipherTextLength = MemoryLayout<UInt32>.size
    
    static func encrypt(data dataConvertible: DataConvertible, using publicKeyOwner: PublicKeyOwner) throws -> Data {
        let data = dataConvertible.asData
        // 0. Here follows ECEIS algorithm (steps copied from Radix DLT Java library)
        // 1. The destination is this publicKey
        let point: EllipticCurvePoint
        do {
            point = try EllipticCurvePoint.decodePointFromPublicKey(publicKeyOwner.publicKey)
        } catch let decodePublicKeyError as EllipticCurvePoint.Error {
            throw DecryptionError.failedToDecodePublicKeyPoint(error: decodePublicKeyError)
        } catch { incorrectImplementation("unhandled error: \(error)") }
        
        
        // 2. Generate 16 random bytes using a secure random number generator. Call them IV
        // swiftlint:disable:next identifier_name
        let iv = try securelyGenerateBytes(count: byteCountInitializationVector)
        
        // 3. Generate a new ephemeral EC key pair
        let ephermalKeyPair = KeyPair()
        
        // 4. Do an EC point multiply with this.getPublicKey() and ephemeral private key. This gives you a point M.
        let pointM = point * ephermalKeyPair.privateKey
        
        // 5. Use the X component of point M and calculate the SHA512 hash H.
        let hashH = RadixHash(unhashedData: pointM.x.asData, hashedBy: Sha512TwiceHasher()).asData
        assert(hashH.length == byteCountHashH)
        
        // 6. The first 32 bytes of H are called key_e and the last 32 bytes are called key_m.
        let keyDataE = hashH.prefix(byteCountHashH/2)
        let keyDataM = hashH.suffix(byteCountHashH/2)
        
        // 7. Pad the input text to a multiple of 16 bytes, in accordance to PKCS7.
        // 8. Encrypt the data with AES-256-CBC, using IV as initialization vector, `keyDataE` as encryption key and the padded input text as payload.
        let cipherText = try Crypt.encrypt(initializationVector: iv, data: data, keyE: keyDataE)
        
        // 9. Calculate a 32 byte MAC, using keyDataM as salt and `IV + ephemeral.pub + cipherText` as data
        let macData = try calculateMAC(
            salt: keyDataM,
            initializationVector: iv,
            ephemeralPublicKey: ephermalKeyPair.publicKey,
            cipherText: cipherText
        )
        assert(macData.length == byteCountMac)
        
        // 10. Concatenate: IV | ephemeral.pub.length | ephemeral.pub | cipherText.length | cipherText | MAC
        func encodeCipherTextLength() -> Data {
            let cipherTextLength = UInt32(cipherText.length)
            let bigEndianInt32Bytes = CFSwapInt32HostToBig(cipherTextLength)
            return bigEndianInt32Bytes.asData
        }
        let ephermalPublicKeyLength = Byte(ephermalKeyPair.publicKey.length).asData
        let ephermalPublicKey = ephermalKeyPair.publicKey.asData
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
    
    enum DecryptionError: Swift.Error, Equatable {
        case failedToConvertPublicKeyLengthDataToInteger
        case failedToConvertCipherTextLengthDataToInteger
        case macMismatch(expected: Data, butGot: Data)
        case keyMismatch
        case failedToDecodePublicKeyPoint(error: EllipticCurvePoint.Error)
    }
    
    static func decrypt(data dataConvertible: DataConvertible, using signing: Signing) throws -> Data {
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
        let hashH = RadixHash(unhashedData: pointM.x.asData, hashedBy: Sha512TwiceHasher()).asData
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
            log.verbose("Expected MAC:\n<\(mac.hex)>")
            log.verbose("Calculated MAC:\n<\(calculatedMac.hex)>")
            throw DecryptionError.macMismatch(expected: mac, butGot: calculatedMac)
        }
        
        // 8. Decrypt the cipher text with AES-256-CBC, using IV as initialization vector, key_e as decryption key and the cipher text as payload. The output is the padded input text.
        let decrypted = try Crypt.decrypt(initializationVector: iv, data: cipherText, keyE: keyDataE)
        
        return decrypted
    }
}

// MARK: ECIES.DecryptionError + Equatable
extension ECIES.DecryptionError {
    public static func == (lhs: ECIES.DecryptionError, rhs: ECIES.DecryptionError) -> Bool {
        switch (lhs, rhs) {
        case (.macMismatch, .macMismatch): return true
        case (.macMismatch, _): return false
        case (.keyMismatch, .keyMismatch): return true
        case (.keyMismatch, _): return false
        case (.failedToDecodePublicKeyPoint, .failedToDecodePublicKeyPoint): return true
        case (.failedToDecodePublicKeyPoint, _): return false
        case (.failedToConvertCipherTextLengthDataToInteger, .failedToConvertCipherTextLengthDataToInteger): return true
        case (.failedToConvertCipherTextLengthDataToInteger, _): return false
        case (.failedToConvertPublicKeyLengthDataToInteger, .failedToConvertPublicKeyLengthDataToInteger): return true
        case (.failedToConvertPublicKeyLengthDataToInteger, _): return false
        }
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

public final class Crypt {
    
    public enum Operation {
        case encrypt
        case decrypt
    }
}

public extension Crypt {
    static func encrypt(initializationVector iv: DataConvertible, data: DataConvertible, keyE: DataConvertible) throws -> Data {
        return try crypt(operation: .encrypt, initializationVector: iv, data: data, keyE: keyE)
    }
    
    static func decrypt(initializationVector iv: DataConvertible, data: DataConvertible, keyE: DataConvertible) throws -> Data {
        return try crypt(operation: .decrypt, initializationVector: iv, data: data, keyE: keyE)
    }
}

private extension Crypt {
    static func crypt(operation: Operation, initializationVector iv: DataConvertible, data: DataConvertible, keyE: DataConvertible) throws -> Data {
        let aes = try AES(key: keyE.bytes, blockMode: CBC(iv: iv.bytes), padding: Padding.pkcs7)
        switch operation {
        case .decrypt: return try aes.decrypt(data.bytes).asData
        case .encrypt: return try aes.encrypt(data.bytes).asData
        }
    }
}

// swiftlint:enable all
