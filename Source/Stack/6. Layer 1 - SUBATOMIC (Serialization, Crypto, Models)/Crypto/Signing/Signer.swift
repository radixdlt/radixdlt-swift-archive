//
//  Signer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
    
    static func sign(text: String, encoding: String.Encoding = .utf8, privateKey: PrivateKey) throws -> Signature {
        let message = try SignableMessage(string: text, encoding: encoding)
        return try sign(message, privateKey: privateKey)
    }
}
