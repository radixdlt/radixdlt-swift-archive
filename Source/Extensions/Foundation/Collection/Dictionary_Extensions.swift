//
//  Dictionary_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Dictionary {
    mutating func valueForKey(key: Key, ifAbsent createValue: () -> Value) -> Value {
        if let value = valueFor(key: key) {
            return value
        } else {
            let value = createValue()
            self[key] = value
            return value
        }
    }
}
