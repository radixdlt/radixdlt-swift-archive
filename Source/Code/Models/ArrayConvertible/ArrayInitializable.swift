//
//  ArrayInitializable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ArrayInitializable: ExpressibleByArrayLiteral {
    associatedtype Element
    init(elements: [Element])
}

// MARK: - Convenience Init
public extension ArrayInitializable {
    init(_ elements: [Element]) {
        self.init(elements: elements)
    }
    
    init(_ elements: Element...) {
        self.init(elements: elements)
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension ArrayInitializable {
    public init(arrayLiteral elements: Element...) {
        self.init(elements: elements)
    }
}
