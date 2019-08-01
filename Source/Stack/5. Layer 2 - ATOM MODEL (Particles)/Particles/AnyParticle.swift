//
//  AnyParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AnyParticle: Hashable {
    
    private let _getParticle: () -> ParticleConvertible
    private let _hashInto: (inout Swift.Hasher) -> Void
    
    public init(someParticle: ParticleConvertible) {
        self._getParticle = { someParticle }
        self._hashInto = { $0.combine(someParticle.hashEUID) }
    }
    
}

public extension AnyParticle {
    func getParticle() -> ParticleConvertible {
        return self._getParticle()
    }
}

public extension AnyParticle {
    static func == (lhs: AnyParticle, rhs: AnyParticle) -> Bool {
        return lhs.getParticle().hashEUID == rhs.getParticle().hashEUID
    }
    
    func hash(into hasher: inout Hasher) {
        self._hashInto(&hasher)
    }
}
