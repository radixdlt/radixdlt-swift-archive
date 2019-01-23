//
//  SpunParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SpunParticle: Codable {
    public let particle: ParticleConvertible
    public let spin: Spin
}

// MARK: - Codable
public extension SpunParticle {
    init(from decoder: Decoder) throws {
        implementMe
    }
    
    func encode(to encoder: Encoder) throws {
        implementMe
    }
}

public extension SpunParticle {
    static func up(particle: ParticleConvertible) -> SpunParticle {
        return SpunParticle(particle: particle, spin: .up)
    }
    
    static func down(particle: ParticleConvertible) -> SpunParticle {
        return SpunParticle(particle: particle, spin: .down)
    }
}
