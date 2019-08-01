//
//  Encryptor.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
        throw ECIES.DecryptionError.keyMismatch
    }
}
