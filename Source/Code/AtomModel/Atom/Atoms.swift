//
//  Atoms.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Atoms: Codable, ExpressibleByArrayLiteral, Collection {
    
    public typealias Element = Atom
    public let atoms: [Element]
    public init(atoms: [Element] = []) {
        self.atoms = atoms
    }
}

// MARK: - Codable
public extension Atoms {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(atoms: try container.decode([Element].self))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(atoms)
    }
}

// MARK: - Collection
public extension Atoms {
    typealias Index = Array<Element>.Index
    var startIndex: Index {
        return atoms.startIndex
    }
    var endIndex: Index {
        return atoms.endIndex
    }
    subscript(position: Index) -> Element {
        return atoms[position]
    }
    func index(after index: Index) -> Index {
        return atoms.index(after: index)
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension Atoms {
    init(arrayLiteral atoms: Element...) {
        self.init(atoms: atoms)
    }
}
