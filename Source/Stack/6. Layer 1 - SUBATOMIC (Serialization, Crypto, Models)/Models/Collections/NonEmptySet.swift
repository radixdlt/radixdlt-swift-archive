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

extension Array where Element: Hashable {
    func containsDuplicates() -> Bool {
        let numberOfElementsInArray = count
        let numberOfElementsInSet = Set(self).count
        let containsDuplicates = numberOfElementsInSet < numberOfElementsInArray
        return containsDuplicates
    }
}

public extension NonEmptySet {
    
    init(array: [Element]) throws {
        guard !array.containsDuplicates() else {
            throw Error.cannotCreateSetFromArrayThatContainsDuplicates
        }
        try self.init(set: array.asSet)
    }
    
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
        case cannotCreateSetFromArrayThatContainsDuplicates
    }
}

public extension ArrayConvertible {
    func randomElement() -> Element? {
        guard !isEmpty else { return nil }
        let randomInt = Int.random(in: 0..<count)
        let randomIndex = self.index(self.startIndex, offsetBy: randomInt)
        return self[randomIndex]
    }
}

public extension NonEmptySet {
    func randomElement() -> Element {
        let randomInt = Int.random(in: 0..<count)
        let randomIndex = self.index(elements.startIndex, offsetBy: randomInt)
        return elements[randomIndex]
    }
}
