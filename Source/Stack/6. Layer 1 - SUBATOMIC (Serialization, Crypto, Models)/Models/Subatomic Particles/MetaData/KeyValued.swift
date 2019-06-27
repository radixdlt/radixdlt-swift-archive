//
//  KeyValued.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol KeyValued: ExpressibleByDictionaryLiteral where Key: Hashable {
    var keys: Dictionary<Key, Value>.Keys { get }
    var values: Dictionary<Key, Value>.Values { get }
    func inserting(value: Value, forKey key: Key) -> Self
    func containsValue(forKey key: Key) -> Bool
    func contains(where predicate: ((key: Key, value: Value)) throws -> Bool) rethrows -> Bool
    func firstKeyForValue(_ value: Value) -> Key?
    func valueFor(key: Key) -> Value?
}

extension Dictionary: KeyValued {
    public func valueFor(key: Key) -> Value? {
        return self[key]
    }
    
    public func inserting(value: Value, forKey key: Key) -> [Key: Value] {
        var dictionary = self
        dictionary.updateValue(value, forKey: key)
        return dictionary
    }
    
    public func firstKeyForValue(_ needle: Value) -> Key? {
        abstract()
    }
}

extension Dictionary where Value: Equatable {
    public func firstKeyForValue(_ needle: Value) -> Key? {
        return first(where: { $0.value == needle })?.key
    }
}

public extension KeyValued {
    func containsValue(forKey key: Key) -> Bool {
        return valueFor(key: key) != nil
    }
    
    func contains(onThrow: () -> Bool, where predicate: ((key: Key, value: Value)) throws -> Bool) -> Bool {
        return contains(where: {
            do {
                return try predicate($0)
            } catch {
                return onThrow()
            }
        })
    }
}

extension KeyValued where Key == MetaDataKey {
    var containsTimestamp: Bool {
        return containsValue(forKey: .timestamp)
    }
}
