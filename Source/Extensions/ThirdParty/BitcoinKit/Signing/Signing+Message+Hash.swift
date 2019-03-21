//
//  Signing+Message+Hash.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-15.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

extension BitcoinKit.Crypto {
    
    static func sign(hashedData: Data, privateKey: BitcoinKit.PrivateKey) throws -> Data {
        guard hashedData.count == 32 else {
            throw BitcoinKit.CryptoError.signFailed
        }
        return try BitcoinKit.Crypto.sign(hashedData, privateKey: privateKey)
    }
}
