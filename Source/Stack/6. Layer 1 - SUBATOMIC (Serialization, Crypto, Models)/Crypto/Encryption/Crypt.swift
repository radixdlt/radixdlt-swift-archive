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

// This is this is the only file where we import CryptoSwift, it is because Apple's CryptoKit does not `CBC` mode with `AES`
// we could drop CryptoSwift in favour of using `CommonCrypto.h`, like e.g.:
// https://gist.github.com/hfossli/7165dc023a10046e2322b0ce74c596f8
import CryptoSwift

public struct Crypt {
    public init() {}
}

public extension Crypt {
    enum Operation {
        case encrypt
        case decrypt
    }
}

// swiftlint:disable identifier_name

public extension Crypt {
    func encrypt(initializationVector iv: DataConvertible, data: DataConvertible, keyE: DataConvertible) throws -> Data {
        return try crypt(operation: .encrypt, initializationVector: iv, data: data, keyE: keyE)
    }
    
    func decrypt(initializationVector iv: DataConvertible, data: DataConvertible, keyE: DataConvertible) throws -> Data {
        return try crypt(operation: .decrypt, initializationVector: iv, data: data, keyE: keyE)
    }
}

private extension Crypt {
    func crypt(operation: Operation, initializationVector iv: DataConvertible, data: DataConvertible, keyE: DataConvertible) throws -> Data {
        let aes = try CryptoSwift.AES(key: keyE.bytes, blockMode: CBC(iv: iv.bytes), padding: Padding.pkcs7)
        switch operation {
        case .decrypt: return try aes.decrypt(data.bytes).asData
        case .encrypt: return try aes.encrypt(data.bytes).asData
        }
    }
}

// swiftlint:enable identifier_name
