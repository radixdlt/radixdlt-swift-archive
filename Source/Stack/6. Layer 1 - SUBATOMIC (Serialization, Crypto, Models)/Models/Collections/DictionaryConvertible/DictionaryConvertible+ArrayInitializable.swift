//
//  DictionaryConvertible+ArrayInitializable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension DictionaryConvertible where Self: ArrayInitializable, Element == (key: Key, value: Value) {
    
    static func mapFromTuples(_ tuples: [Element]) throws -> Map {
        return try tuples.reduce(into: [:]) { map, tuple in
            let key = tuple.key
            let value = tuple.value
            if let existingValue = map[key] {
                throw DictionaryError<Key, Value>.duplicate(values: [existingValue, value], forKey: key)
            }
            map[key] = value
        }
    }
    
    public init(elements tuples: [Element]) {
        do {
            self.init(dictionary: try Self.mapFromTuples(tuples))
        } catch {
            fatalError("Bad key-values passed, error: \(error)")
        }
    }
}
