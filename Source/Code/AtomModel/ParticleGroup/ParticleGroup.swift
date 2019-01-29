//
//  ParticleGroup.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct ParticleGroup: Codable, Collection, ExpressibleByArrayLiteral {
    public typealias Element = SpunParticle
    
    public let spunParticles: [Element]
}

// MARK: - Codable
public extension ParticleGroup {
    public enum CodingKeys: String, CodingKey {
        case spunParticles = "particles"
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension ParticleGroup {
    init(arrayLiteral spunParticles: SpunParticle...) {
        self.init(spunParticles: spunParticles)
    }
}

// MARK: - Collection
public extension ParticleGroup {
    typealias Index = Array<Element>.Index
    var startIndex: Index {
        return spunParticles.startIndex
    }
    var endIndex: Index {
        return spunParticles.endIndex
    }
    subscript(position: Index) -> Element {
        return spunParticles[position]
    }
    func index(after index: Index) -> Index {
        return spunParticles.index(after: index)
    }
}
