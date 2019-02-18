//
//  ParticleGroups.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct ParticleGroups: Codable, ExpressibleByArrayLiteral, Collection {
    
    public typealias Element = ParticleGroup
    public let particleGroups: [Element]
    public init(particleGroups: [Element] = []) {
        self.particleGroups = particleGroups
    }
}

// MARK: - Codable
public extension ParticleGroups {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(particleGroups: try container.decode([Element].self))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(particleGroups)
    }
}

// MARK: - Collection
public extension ParticleGroups {
    typealias Index = Array<Element>.Index
    
    var startIndex: Index {
        return particleGroups.startIndex
    }
    
    var endIndex: Index {
        return particleGroups.endIndex
    }
    
    subscript(position: Index) -> Element {
        return particleGroups[position]
    }
    
    func index(after index: Index) -> Index {
        return particleGroups.index(after: index)
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension ParticleGroups {
    init(arrayLiteral groups: Element...) {
        self.init(particleGroups: groups)
    }
}
