//
//  DictionaryDecodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DictionaryDecodable: Codable, DictionaryConvertible {
    static var valueMapper: (String) throws -> Value { get }
    static var keyMapper: (String) throws -> Key { get }
}

public extension DictionaryDecodable {
    
    static var valueMapper: (String) throws -> Value {
        return {
            try Value(string: $0)
        }
    }
    static var keyMapper: (String) throws -> Key {
        return {
            try Key(string: $0)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let map: Map = try container.decode(StringDictionary.self)
            .mapKeys { try Self.keyMapper($0) }
            .mapValues { try Self.valueMapper($0) }
        self.init(dictionary: map)
    }
}
