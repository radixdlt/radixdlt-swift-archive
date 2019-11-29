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

/// Holder of an array of EncryptedPrivateKey's, called `protectors`.
///
/// These `protectors` have been created by encrypting the privatekey of a temporary "shared key",
/// using the public key of the `readers`, those being able to decrypt some encrypted message.
///
public struct Encryptor {
    private let protectors: [EncryptedPrivateKey]
    
    internal init(protectors: [EncryptedPrivateKey]) {
        self.protectors = protectors
    }
}

public extension Encryptor {
    
    func encodePayload(
        encoder: JSONEncoder = JSONEncoder(),
        encoding: String.Encoding = .default
    ) throws -> Data {
        
        let privateKeysStringArray: [String] = protectors.map { $0.base64 }
        
        // So Swift JSON encoding of strings containing forward slash gets escaped, both using old legacy `JSONSerialization.dataWith`
        // and `JSONEncoder`, this issue has been brought up here: https://stackoverflow.com/questions/47076329/swift-string-escaping-when-serializing-to-json-using-codable
        // The ugly work around is replacing the escaped forward slashes "\/", with just the forward slash "/".
        let jsonDataWithEscapedForwardSlash = try encoder.encode(privateKeysStringArray)
        
        let jsonStringWithEscapedForwardSlash = String(data: jsonDataWithEscapedForwardSlash)
        
        let jsonStringWithNonEscapedForwardSlash = jsonStringWithEscapedForwardSlash.replacingOccurrences(of: "\\/", with: "/")
        
        return jsonStringWithNonEscapedForwardSlash.toData(encodingForced: encoding)
    }
    
    static func fromData(
        _ encryptedData: Data,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) throws -> Encryptor {

        let protectorsAsStrings = try jsonDecoder.decode([String].self, from: encryptedData)
        
        let protectors = try protectorsAsStrings.map { try EncryptedPrivateKey(base64String: $0) }
        return Encryptor(protectors: protectors)
    }

    func decrypt(data encryptedData: Data, using key: Signing) throws -> Data {

        for protector in self.protectors {
            do {
                return try key.decrypt(encryptedData, sharedKey: protector)
            } catch { /* try next one */ }
        }
        throw DecryptionError.keyMismatch
    }
}
