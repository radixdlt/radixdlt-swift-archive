//
//  Sequence_Extension.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Sequence where Element: Hashable {
    var asSet: Set<Element> {
        return Set(self)
    }
}

public enum Order {
    case asending
    case descending
}

public extension Sequence {
    
    func sorted<Property>(by keyPath: KeyPath<Element, Property>, order: Order = .asending) -> [Element] where Property: Comparable {
        return sorted(by: {
            let lhs = $0[keyPath: keyPath]
            let rhs = $1[keyPath: keyPath]
            switch order {
            case .asending: return lhs < rhs
            case .descending: return lhs > rhs
            }
        })
    }
}
