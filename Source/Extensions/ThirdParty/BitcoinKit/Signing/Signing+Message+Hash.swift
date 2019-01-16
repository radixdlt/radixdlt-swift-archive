//
//  Signing+Message+Hash.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-15.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

public extension BitcoinKit.Crypto {
    static func sign(hashedData: Data, privateKey: BitcoinKit.PrivateKey) throws -> Data {
        guard hashedData.count == 32 else {
            print("Signing failed since hashed data has incorrect length")
            throw BitcoinKit.CryptoError.signFailed
        }
        return try BitcoinKit.Crypto.sign(hashedData, privateKey: privateKey)
    }
    
    static func sign(message: String, encoding: String.Encoding = .utf8, privateKey: BitcoinKit.PrivateKey) throws -> Data {
        guard let encoded = message.data(using: encoding) else {
            print("Signing failed since message encoding failed.")
            throw BitcoinKit.CryptoError.signFailed
        }
        return try sign(hashedData: Crypto.sha256(encoded), privateKey: privateKey)
    }
}
