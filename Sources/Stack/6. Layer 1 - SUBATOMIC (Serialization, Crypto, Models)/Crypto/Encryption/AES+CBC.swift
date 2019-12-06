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

import CommonCrypto

// TODO remove this when we have migrated from AES with `CBC` to AES with `GCM`, then we can use `CryptoKit` instead of CommonCrypto

internal struct AES256 {
    
    private var key: Data
    private var initializationVector: Data
    
    init(
        key: Data,
        initializationVector: Data
    ) throws {
        
        guard key.count == kCCKeySizeAES256 else {
            throw Error.badKeyLength
        }
        guard initializationVector.count == kCCBlockSizeAES128 else {
            throw Error.badLengthOfInitializationVector
        }
        self.key = key
        self.initializationVector = initializationVector
    }
}

internal extension AES256 {
    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: .encrypt)
    }
    
    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: .decrypt)
    }
    
    enum Error: Swift.Error, Equatable {
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badLengthOfInitializationVector
    }
}
 
internal extension AES256 {
    
    func crypt(input: Data, operation: Crypt.Operation) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        
        input.withUnsafeBytes { encryptedBytes in
            initializationVector.withUnsafeBytes { ivBytes in
                key.withUnsafeBytes { keyBytes in
                    
                    status = CCCrypt(
                        operation.ccOperation,              // encrypt or decrypt
                        CCAlgorithm(kCCAlgorithmAES128),    // algorithm
                        CCOptions(kCCOptionPKCS7Padding),   // options
                        keyBytes.baseAddress!,              // key
                        key.count,                          // key length
                        ivBytes.baseAddress!,               // iv
                        encryptedBytes.baseAddress!,        // dataIn
                        input.count,                        // dataInLength
                        &outBytes,                          // dataOut
                        outBytes.count,                     // dataOutAvailable
                        &outLength)                         // dataOutMoved
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw Error.cryptoFailed(status: status)
        }
        
        return Data(bytes: UnsafePointer<UInt8>(outBytes), count: outLength)
    }
}

private extension Crypt.Operation {
    var ccOperation: CCOperation {
        switch self {
        case .decrypt: return CCOperation(kCCDecrypt)
        case .encrypt: return CCOperation(kCCEncrypt)
        }
    }
}
