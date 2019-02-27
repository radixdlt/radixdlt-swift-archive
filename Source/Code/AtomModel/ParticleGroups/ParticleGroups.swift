//
//  ParticleGroups.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct ParticleGroups: ArrayDecodable {
    
    public let particleGroups: [ParticleGroup]
    public init(particleGroups: [ParticleGroup] = []) {
        self.particleGroups = particleGroups
    }
}

// MARK: - ArrayDecodable
public extension ParticleGroups {
    public typealias Element = ParticleGroup
    var elements: [Element] {
        return particleGroups
    }
    init(elements: [Element]) {
        self.init(particleGroups: elements)
    }
}
