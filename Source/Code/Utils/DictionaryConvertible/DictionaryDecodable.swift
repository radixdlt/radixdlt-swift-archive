//
//  DictionaryDecodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DictionaryDecodable: Decodable, DictionaryConvertible {
    static var keyDecoder: (String) throws -> Key { get }
    static var valueDecoder: (String) throws -> Value { get }
}

public extension DictionaryDecodable where Key: StringInitializable, Value: StringInitializable {
   
    static var keyDecoder: (String) throws -> Key {
        return {
            try Key(string: $0)
        }
    }
    
    static var valueDecoder: (String) throws -> Value {
        return {
            try Value(string: $0)
        }
    }
   
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let map: Map = try container.decode(StringDictionary.self)
            .mapKeys { try Self.keyDecoder($0) }
            .mapValues { try Self.valueDecoder($0) }
        try self.init(validate: map)
    }
}

public protocol DictionaryEncodable: Encodable, DictionaryConvertible {
    static var keyEncoder: (Key) throws -> String { get }
    static var valueEncoder: (Value) throws -> PrefixedStringWithValue { get }
}

public typealias DictionaryCodable = DictionaryDecodable & DictionaryEncodable

extension String: PrefixedJsonEncodable {
    public var prefixedString: PrefixedStringWithValue {
        return PrefixedStringWithValue(value: self, prefix: .string)
    }
}

// MARK: - Encodable
public extension DictionaryEncodable where Key: StringRepresentable {
    static var keyEncoder: (Key) throws -> String {
        return {
            return $0.stringValue
        }
    }
}

public extension DictionaryEncodable where Value: PrefixedJsonEncodable {
    static var valueEncoder: (Value) throws -> PrefixedStringWithValue {
        return {
            $0.prefixedString
        }
    }
}

public extension Encodable where Self: DictionaryEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let map = try [String: String](uniqueKeysWithValues: dictionary.map {
            (
                try Self.keyEncoder($0.key),
                try Self.valueEncoder($0.value).identifer
            )
        })
        try container.encode(map)
    }
}
