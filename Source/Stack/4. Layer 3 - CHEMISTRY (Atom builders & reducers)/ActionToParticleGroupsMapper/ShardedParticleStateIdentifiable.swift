//
//  ShardedParticleStateIdentifiable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ShardedParticleStateIdentifiable {
    var particleType: ParticleConvertible.Type { get }
    var address: Address { get }
}

public struct ShardedParticleStateId<Particle>: ShardedParticleStateIdentifiable where Particle: ParticleConvertible {
    public let typeOfParticle: Particle.Type
    public let address: Address
}
public extension ShardedParticleStateId {
    var particleType: ParticleConvertible.Type {
        return typeOfParticle
    }
}

public struct AnyShardedParticleStateId: ShardedParticleStateIdentifiable {
    
    private let _getParticleType: () -> ParticleConvertible.Type
    public let address: Address
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: ShardedParticleStateIdentifiable {
        self.address = concrete.address
        self._getParticleType = { concrete.particleType }
    }
}
public extension AnyShardedParticleStateId {
    var particleType: ParticleConvertible.Type {
        return _getParticleType()
    }
}
