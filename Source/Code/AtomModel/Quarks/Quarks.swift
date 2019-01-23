//
//  Quarks.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Quarks: Codable, Collection, ExpressibleByArrayLiteral {
    public typealias Element = QuarkConvertible
    private let quarks: [Element]
    public init(quarks: [Element] = []) {
        self.quarks = quarks
    }
}

// MARK: - Codable
public extension Quarks {
    init(from decoder: Decoder) throws {
        implementMe
    }
    
    func encode(to encoder: Encoder) throws {
        implementMe
    }
}

// MARK: - Collection
public extension Quarks {
    typealias Index = Array<Element>.Index
    var startIndex: Index {
        return quarks.startIndex
    }
    var endIndex: Index {
        return quarks.endIndex
    }
    subscript(position: Index) -> Element {
        return quarks[position]
    }
    func index(after index: Index) -> Index {
        return quarks.index(after: index)
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension Quarks {
    init(arrayLiteral quarks: Element...) {
        self.init(quarks: quarks)
    }
}
