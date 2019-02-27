//
//  ArrayConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ArrayConvertible: ExpressibleByArrayLiteral, Collection {
    var elements: [Element] { get }
    init(elements: [Element])
}

// MARK: - Convenience Init
public extension ArrayConvertible {
    init(_ elements: [Element]) {
        self.init(elements: elements)
    }
    
    init(_ elements: Element...) {
        self.init(elements: elements)
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension ArrayConvertible {
    public init(arrayLiteral elements: Element...) {
        self.init(elements: elements)
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
