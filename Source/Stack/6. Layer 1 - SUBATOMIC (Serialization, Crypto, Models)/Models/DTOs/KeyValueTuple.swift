//
//  KeyValueTuple.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

internal protocol KeyValueTuple {
    associatedtype Key: Hashable
    associatedtype Value
    var key: Key { get }
    var value: Value { get }
}

internal struct KeyValuePair<Key, Value>: KeyValueTuple where Key: Hashable {
    let key: Key
    let value: Value
}

extension Array where Element: KeyValueTuple {
    func toDictionary() -> [Element.Key: Element.Value] {
        return [Element.Key: Element.Value].init(uniqueKeysWithValues: self.map { ($0.key, $0.value) })
    }
}
