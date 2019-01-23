//
//  PublicKey.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct PublicKey: Codable, Hashable {
    public let data: Data
    public init(data: Data) {
        self.data = data
    }
}

public extension PublicKey {
    init(private privateKey: PrivateKey) {
        implementMe
    }
}
