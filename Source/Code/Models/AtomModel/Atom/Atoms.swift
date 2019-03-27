//
//  Atoms.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Atoms: ArrayCodable {
    
    public let atoms: [Atom]
    public init(atoms: [Atom] = []) {
        self.atoms = atoms
    }
}

// MARK: - ArrayDecodable
public extension Atoms {
    typealias Element = Atom
    var elements: [Element] {
        return atoms
    }
    init(elements: [Element]) {
        self.init(atoms: elements)
    }
}
