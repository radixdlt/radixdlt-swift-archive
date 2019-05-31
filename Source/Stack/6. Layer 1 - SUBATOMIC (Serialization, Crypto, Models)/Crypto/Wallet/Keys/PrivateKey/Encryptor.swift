//
//  Encryptor.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Encryptor {
    
    private let protectors: [EncryptedPrivateKey]
    
    init(protectors: [EncryptedPrivateKey]) {
        self.protectors = protectors
    }
}

// MARK: - Convenience
public extension Encryptor {
    
    init(sharedKey: KeyPair, readers: [PublicKey]) throws {
        let encryptedPrivateKeys = try readers.map { try sharedKey.encryptPrivateKey(withPublicKey: $0) }
        self.init(protectors: encryptedPrivateKeys)
    }
}

public extension Encryptor {
    func encodePayload(encoder: JSONEncoder = JSONEncoder(), encoding: String.Encoding = .default) throws -> Data {
        
        let privateKeysStringArray: [String] = protectors.map { $0.base64 }
        
        // So Swift JSON encoding of strings containing forward slash gets escaped, both using old legacy `JSONSerialization.dataWith`
        // and `JSONEncoder`, this issue has been brought up here: https://stackoverflow.com/questions/47076329/swift-string-escaping-when-serializing-to-json-using-codable
        // The ugly work around is replacing the escaped forward slashes "\/", with just the forward slash "/".
        let jsonDataWithEscapedForwardSlash = try encoder.encode(privateKeysStringArray)
        
        let jsonStringWithEscapedForwardSlash = String(data: jsonDataWithEscapedForwardSlash)
        
        // swiftlint:disable:next identifier_name
        let jsonStringWithNonEscapedForwardSlash = jsonStringWithEscapedForwardSlash.replacingOccurrences(of: "\\/", with: "/")
        
        return jsonStringWithNonEscapedForwardSlash.toData(encodingForced: encoding)
    }
}
