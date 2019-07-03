//
//  NonEmptyArray.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable opening_brace

public struct NonEmptyArray<ElementInArray>:
    ArrayConvertible,
    ArrayInitializable,
    Throwing
{
    public typealias Element = ElementInArray
    // swiftlint:enable opening_brace
    
    public let elements: [Element]

    public init(unvalidated: [Element]) throws {
        if unvalidated.isEmpty {
            throw Error.arrayCannotBeEmpty
        }
        self.elements = unvalidated
    }
}

public extension NonEmptyArray {
    init(elements: [Element]) {
        do {
            try self.init(unvalidated: elements)
        } catch {
            fatalError("Bad value passed, got error: \(error), passed value: \(elements)")
        }
    }
}

public extension NonEmptyArray {
    enum Error: Swift.Error {
        case arrayCannotBeEmpty
    }
}
