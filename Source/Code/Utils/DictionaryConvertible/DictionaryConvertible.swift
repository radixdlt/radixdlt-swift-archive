//
//  DictionaryConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DictionaryConvertible: Collection, KeyValued {
    typealias Map = [Key: Value]
    var dictionary: Map { get }
    init(dictionary: Map)
    init(validate: Map) throws
    subscript(key: Key) -> Value? { get }
}

public extension DictionaryConvertible {
    var keys: Dictionary<Key, Value>.Keys { return dictionary.keys }
    var values: Dictionary<Key, Value>.Values { return dictionary.values }
}

public extension DictionaryConvertible {
    init(validate valid: Map) throws {
        self.init(dictionary: valid)
    }
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
