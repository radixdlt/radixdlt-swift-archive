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
}

extension Dictionary: KeyValued {}

extension KeyValued where Key == MetaDataKey {
    var containsTimestamp: Bool {
        return keys.contains(.timestamp)
    }
}
