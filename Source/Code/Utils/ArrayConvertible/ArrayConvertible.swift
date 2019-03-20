//
//  ArrayConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// An Array-like type
public protocol ArrayConvertible:
    LengthMeasurable,
    Collection {
// swiftlint:enable colon
    var elements: [Element] { get }
}

// MARK: - LengthMeasurable Conformance
public extension ArrayConvertible {
    var length: Int {
        return elements.count
    }
}

// MARK: - Collection
public extension ArrayConvertible {
    typealias ArrayIndex = Array<Element>.Index
    
    var startIndex: ArrayIndex {
        return elements.startIndex
    }
    
    var endIndex: ArrayIndex {
        return elements.endIndex
    }
    
    subscript(position: ArrayIndex) -> Element {
        return elements[position]
    }
    
    func index(after index: ArrayIndex) -> ArrayIndex {
        return elements.index(after: index)
    }
}
