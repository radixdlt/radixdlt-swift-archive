//
//  TokenPermissions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenPermissions: Equatable, Codable, ExpressibleByDictionaryLiteral, Collection {
    public typealias Key = TokenAction
    public typealias Value = TokenPermission
    public let map: [Key: Value]
}

// MARK: - Decodable
public extension TokenPermissions {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringMap = try container.decode([String: String].self)
        let map = try [Key: Value](uniqueKeysWithValues: stringMap.map {
            (
                try Key(string: $0.key),
                try Dson<Value>(string: $0.value).value
            )
        })
        self.init(map: map)
    }
}

// MARK: - Encodable
public extension TokenPermissions {
    func encode(to encoder: Encoder) throws {
       implementMe
    }
}

// MARK: - Subscript
public extension TokenPermissions {
    subscript(key: Key) -> Value? {
        return map[key]
    }
}

// MARK: - Collection
public extension TokenPermissions {
    typealias Element = Dictionary<Key, Value>.Element
    typealias Index = Dictionary<Key, Value>.Index
    var startIndex: Index {
        return map.startIndex
    }
    var endIndex: Index {
        return map.endIndex
    }
    subscript(position: Index) -> Element {
        return map[position]
    }
    func index(after index: Index) -> Index {
        return map.index(after: index)
    }
}

// MARK: - ExpressibleByDictionaryLiteral
public extension TokenPermissions {
    init(dictionaryLiteral permissions: (Key, Value)...) {
        self.init(map: Dictionary(uniqueKeysWithValues: permissions))
    }
}
