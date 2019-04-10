//
//  SpunParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SpunParticle<Particle> where Particle: ParticleConvertible {
    
    public let spin: Spin
    public let particle: Particle
    
    public init(spin: Spin = .down, particle: Particle) {
        self.spin = spin
        self.particle = particle
    }
}
