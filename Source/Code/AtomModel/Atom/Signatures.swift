//
//  Signatures.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Signatures: ExpressibleByDictionaryLiteral, Codable {
    public typealias Key = String
    public typealias Value = Signature
    public let map: [Key: Value]
}

public extension Signatures {
    init(dictionaryLiteral signatures: (Key, Value)...) {
        self.init(map: Dictionary(uniqueKeysWithValues: signatures))
    }
}
