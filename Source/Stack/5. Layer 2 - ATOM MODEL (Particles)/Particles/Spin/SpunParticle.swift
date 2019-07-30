//
//  SpunParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SpunParticle<Particle>: Throwing where Particle: ParticleConvertible {
    
    public let spin: Spin
    public let particle: Particle
    
    private init(spin: Spin, particle: Particle) {
        self.spin = spin
        self.particle = particle
    }
    
    public init(anySpunParticle: AnySpunParticle) throws {
        guard let particle = anySpunParticle.particle as? Particle else {
            throw Error.particleTypeMismatch
        }
        self.init(spin: anySpunParticle.spin, particle: particle)
    }
}

public extension SpunParticle {
    enum Error: Swift.Error, Equatable {
        case particleTypeMismatch
    }
}

public struct UpParticle<Particle>: Throwing where Particle: ParticleConvertible {
    
    public let particle: Particle
    
    public init(spunParticle: SpunParticle<Particle>) throws {
        guard spunParticle.spin == .up else {
            throw Error.particleDidNotHaveSpinUp
        }
        self.particle = spunParticle.particle
    }
    
    public init(anySpunParticle: AnySpunParticle) throws {
        guard anySpunParticle.spin == .up else {
            throw Error.particleDidNotHaveSpinUp
        }
        guard let particle = anySpunParticle.particle as? Particle else {
            throw Error.particleTypeMismatch
        }
        self.particle = particle
    }
    
    public init(anyUpParticle: AnyUpParticle) throws {
        guard let particle = anyUpParticle.particle as? Particle else {
            throw Error.particleTypeMismatch
        }
        self.particle = particle
    }
}

public extension UpParticle {
    enum Error: Swift.Error, Equatable {
        case particleDidNotHaveSpinUp
        case particleTypeMismatch
    }
}

public struct AnyUpParticle: Throwing {
    public let particle: ParticleConvertible
    
    /// Only use this initializer when you KNOW for sure that the spin is `Up`.
    internal init(particle: ParticleConvertible) {
        self.particle = particle
    }
 
    public init(anySpunParticle: AnySpunParticle) throws {
        guard anySpunParticle.spin == .up else {
            throw Error.particleDidNotHaveSpinUp
        }
    
        self.init(particle: anySpunParticle.particle)
    }
}

public extension AnyUpParticle {
    enum Error: Swift.Error, Equatable {
        case particleDidNotHaveSpinUp
    }
}
