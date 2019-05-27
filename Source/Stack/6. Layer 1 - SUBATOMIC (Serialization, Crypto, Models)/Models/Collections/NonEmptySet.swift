//
//  NonEmptySet.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable opening_brace

public struct NonEmptySet<ElementInSet>:
    ArrayConvertible,
    Throwing,
    Hashable,
    ExpressibleByArrayLiteral
    where
    ElementInSet: Hashable
{
    // swiftlint:enable opening_brace
    
    private let set: Set<ElementInSet>
    
    public init(set: Set<ElementInSet>) throws {
        if set.isEmpty {
            throw Error.setCannotBeEmpty
        }
        self.set = set
    }
}

public extension NonEmptySet {
    init(single: ElementInSet) {
        self.set = Set([single])
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension NonEmptySet {
    init(arrayLiteral elements: Element...) {
        do {
            try self.init(set: Set(elements))
        } catch {
            fatalError("Passed bad array: \(elements), error: \(error)")
        }
    }
}

public extension NonEmptySet {
    typealias Element = ElementInSet
    var elements: [Element] { return set.asArray }
}

public extension NonEmptySet {
    enum Error: Swift.Error {
        case setCannotBeEmpty
    }
}

