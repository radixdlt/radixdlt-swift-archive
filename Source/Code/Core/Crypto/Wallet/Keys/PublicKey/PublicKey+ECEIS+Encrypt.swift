//
//  PublicKey+ECEIS.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Ownable {
    func encrypt(_ data: DataConvertible) throws -> Data {
        return try ECIES.encrypt(data: data, using: publicKey)
    }
}
