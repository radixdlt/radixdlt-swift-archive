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
import BitcoinKit

public final class Signer {
    static func sign(_ signable: Signable, privateKey: PrivateKey) throws -> Signature {
        let signedData = try BitcoinKit.Crypto.sign(hashedData: signable.signableData, privateKey: privateKey.bitcoinKitPrivateKey)
        let der = try DER(data: signedData)
        return try Signature(der: der)
    }
}

public extension Signer {

    static func sign(hashedData: Data, privateKey: PrivateKey) throws -> Signature {
        let message = try SignableMessage(data: hashedData)
        return try sign(message, privateKey: privateKey)
    }
    
    static func sign(unhashedData: DataConvertible, hashedBy hasher: Hashing = RadixHasher(), privateKey: PrivateKey) throws -> Signature {
        let hashed = hasher.hash(data: unhashedData.asData)
        return try sign(hashedData: hashed, privateKey: privateKey)
    }
    
    static func sign(text: String, encoding: String.Encoding = .default, privateKey: PrivateKey) throws -> Signature {
        let message = try SignableMessage(string: text, encoding: encoding)
        return try sign(message, privateKey: privateKey)
    }
}
