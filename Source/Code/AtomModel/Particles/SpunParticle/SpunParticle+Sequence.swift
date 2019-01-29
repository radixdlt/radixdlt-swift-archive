//
//  SpunParticle+Sequence.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Sequence where Element == SpunParticle {
    func compactMap<P>(type: P.Type) -> [P] where P: ParticleConvertible {
        return compactMap { $0.particle as? P }
    }
    
    func filter(spin: Spin) -> [SpunParticle] {
        return filter { $0.spin == spin }
    }
}
