//
//  MetaData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// In Java library: "MetaDataMap"
public struct MetaData: Codable, Equatable, ExpressibleByDictionaryLiteral, Collection {
    public typealias Key = MetaDataKey
    public typealias Value = String
    public let values: [Key: Value]
}

// MARK: - ExpressibleByDictionaryLiteral
public extension MetaData {
    init(dictionaryLiteral nodes: (Key, Value)...) {
        self.init(values: Dictionary(uniqueKeysWithValues: nodes))
    }
}

// MARK: - Decodable
public extension MetaData {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringMap = try container.decode([String: PrefixedStringWithValue].self)
        let map = [Key: Value](uniqueKeysWithValues: stringMap.map {
            (
                Key($0.key),
                $0.value.stringValue
            )
        })
        self.init(values: map)
    }
}

// MARK: - Encodable
public extension MetaData {
    func encode(to encoder: Encoder) throws {
        implementMe
    }
}

// MARK: - Collection
public extension MetaData {
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

// MARK: - Subscript
public extension MetaData {
    subscript(key: Key) -> Value? {
        return values[key]
    }
}

// MARK: Values for Default Keys
public extension MetaData {
    var timestamp: Date? {
        guard let timestampString = self[.timestamp] else {
            return nil
        }
        return DateFormatter(dateStyle: .full).date(from: timestampString)
    }
}
