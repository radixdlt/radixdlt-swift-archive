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
    public let values: [Key: Value]
}

// MARK: - Decodable
public extension TokenPermissions {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringMap = try container.decode([String: PrefixedStringWithValue].self)
        let map = try [Key: Value](uniqueKeysWithValues: stringMap.map {
            (
                try Key(string: $0.key),
                try Value(string: $0.value.stringValue)
            )
        })
        self.init(values: map)
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
        return values[key]
    }
}

// MARK: - Collection
public extension TokenPermissions {
    typealias Element = Dictionary<Key, Value>.Element
    typealias Index = Dictionary<Key, Value>.Index
    
    var startIndex: Index {
        return values.startIndex
    }
    
    var endIndex: Index {
        return values.endIndex
    }
    
    subscript(position: Index) -> Element {
        return values[position]
    }
    
    func index(after index: Index) -> Index {
        return values.index(after: index)
    }
}

// MARK: - ExpressibleByDictionaryLiteral
public extension TokenPermissions {
    init(dictionaryLiteral permissions: (Key, Value)...) {
        self.init(values: Dictionary(uniqueKeysWithValues: permissions))
    }
}
