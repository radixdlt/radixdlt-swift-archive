//
//  Cache.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class Cache<Key: Hashable, Value> {
    fileprivate let cache = NSCache<CacheKey<Key>, Box<Value>>()
}

// MARK: - Public
public extension Cache {
    
    func value(for key: Key) -> Value? {
        guard let box: Box<Value> = cache.object(forKey: CacheKey(key)) else {
            return nil
        }
        return box.value
    }
    
    func value(for key: Key, elseCreateAndStore create: () -> Value) -> Value {
        if let cached = value(for: key) {
            return cached
        } else {
            let new = create()
            store(new, for: key)
            return new
        }
    }
    
    func store(_ value: Value, for key: Key) {
        cache.setObject(Box(value), forKey: CacheKey(key))
    }
}

// MARK: - CacheKey
public final class CacheKey<H: Hashable>: Hashable {
    public static func == (lhs: CacheKey<H>, rhs: CacheKey<H>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    private let _hash: () -> Int
    public init(_ reference: H) {
        self._hash = { reference.hashValue }
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_hash())
    }
}

// MARK: - Box
public final class Box<Value> {
    public let value: Value
    public init(_ value: Value) {
        self.value = value
    }
}
