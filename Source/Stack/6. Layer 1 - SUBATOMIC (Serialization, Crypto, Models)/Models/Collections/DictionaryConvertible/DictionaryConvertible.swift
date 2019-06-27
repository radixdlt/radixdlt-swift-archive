//
//  DictionaryConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// A KeyValue-d Collection
public protocol DictionaryConvertible:
    KeyValued,
    LengthMeasurable,
    Collection,
    CustomStringConvertible
{
    
// swiftlint:enable colon opening_brace
    
    typealias Map = [Key: Value]
    var dictionary: Map { get }
    init(dictionary: Map)
    init(validate: Map) throws
    subscript(key: Key) -> Value? { get }
    func merging(with other: Self, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> Self
}

// MARK: Default Implementation
public extension DictionaryConvertible {
    init(validate valid: Map) throws {
        self.init(dictionary: valid)
    }
    
    func inserting(value: Value, forKey key: Key) -> Self {
        let updated = dictionary.inserting(value: value, forKey: key)
        return Self(dictionary: updated)
    }
    
    func firstKeyForValue(_ needle: Value) -> Key? {
        abstract()
    }
    
    func valueFor(key: Key) -> Value? {
        return dictionary[key]
    }
    
    func contains(where predicate: ((key: Key, value: Value)) throws -> Bool) rethrows -> Bool {
        return try dictionary.contains(where: predicate)
    }

    func merging(with other: Self, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> Self {
        
        let mergedDictionary = try dictionary.merging(other.dictionary, uniquingKeysWith: combine)
        
        return Self(dictionary: mergedDictionary)
    }
}

public extension DictionaryConvertible where Value: Equatable {
    func firstKeyForValue(_ needle: Value) -> Key? {
        return dictionary.firstKeyForValue(needle)
    }
}

// MARK: - CustomStringConvertible
public extension DictionaryConvertible {
    var description: String {
        return dictionary.map {
            "\($0.key): \($0.value)"
        }.joined(separator: ", ")
    }
}

// MARK: - LengthMeasurable Conformance
public extension DictionaryConvertible {
    var length: Int {
        return keys.count
    }
}

// MARK: - KeyValued Conformance
public extension DictionaryConvertible {
    var keys: Dictionary<Key, Value>.Keys { return dictionary.keys }
    var values: Dictionary<Key, Value>.Values { return dictionary.values }
}

// MARK: - ExpressibleByDictionaryLiteral
public extension DictionaryConvertible {
    init(dictionaryLiteral keyValyes: (Key, Value)...) {
        self.init(dictionary: Dictionary(uniqueKeysWithValues: keyValyes))
    }
}

// MARK: - Subscript
public extension DictionaryConvertible {
    subscript(key: Key) -> Value? {
        return dictionary[key]
    }
}

// MARK: - Collection
public extension DictionaryConvertible {
    typealias DictElement = Dictionary<Key, Value>.Element
    typealias DictIndex = Dictionary<Key, Value>.Index
    
    var startIndex: DictIndex {
        return dictionary.startIndex
    }
    
    var endIndex: DictIndex {
        return dictionary.endIndex
    }
    
    subscript(position: DictIndex) -> DictElement {
        return dictionary[position]
    }
    
    func index(after index: DictIndex) -> DictIndex {
        return dictionary.index(after: index)
    }
}
