//
//  PublicKey.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct PublicKey: Codable {
    public let data: Data
}

public extension PublicKey {
    init(private privateKey: PrivateKey) {
        implementMe
    }
}
