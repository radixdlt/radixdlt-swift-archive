//
//  Signatures.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public let dataFormatVersion = 100

public struct Signatures: Equatable, ExpressibleByDictionaryLiteral, Codable {
    public typealias Key = EUID
    public typealias Value = Signature
    public let map: [Key: Value]
}

// MARK: - ExpressibleByDictionaryLiteral
public extension Signatures {
    init(dictionaryLiteral signatures: (Key, Value)...) {
        self.init(map: Dictionary(uniqueKeysWithValues: signatures))
    }
}

// MARK: - Decodable
public extension Signatures {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringMap = try container.decode([String: Signature].self)
        let map = try [Key: Value](uniqueKeysWithValues: stringMap.map {
            (
                try EUID(string: $0.key),
                $0.value
            )
        })
        self.init(map: map)
    }
}

// MARK: - Encodable
public extension Signatures {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(map)
    }
}
