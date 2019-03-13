//
//  Signatures.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Signatures: Equatable, ExpressibleByDictionaryLiteral, Collection, Codable {
    public typealias Key = EUID
    public typealias Value = Signature
    public let values: [Key: Value]
}

// MARK: - Collection
public extension Signatures {
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
public extension Signatures {
    subscript(key: Key) -> Value? {
        return values[key]
    }
}

// MARK: - ExpressibleByDictionaryLiteral
public extension Signatures {
    init(dictionaryLiteral signatures: (Key, Value)...) {
        self.init(values: Dictionary(uniqueKeysWithValues: signatures))
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
        self.init(values: map)
    }
}

// MARK: - Encodable
public extension Signatures {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
     
        let dictionary = [String: Signature](uniqueKeysWithValues: values.map {
            (
                $0.key.toHexString().stringValue,
                $0.value
            )
        })
        try container.encode(dictionary)
    }
}
