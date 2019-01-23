//
//  Particle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ParticleConvertible: Codable {
    var quarks: Quarks { get }
}

public extension ParticleConvertible {
    func quark<Q>(type: Q.Type) -> Q? where Q: QuarkConvertible {
        return quarks.compactMap { $0 as? Q }.first
    }
    
    func quarkOrCrash<Q>(type: Q.Type) -> Q where Q: QuarkConvertible {
        guard let quark = quark(type: Q.self) else {
            incorrectImplementation("Should have at least one quark of type: \(Q.self)")
        }
        return quark
    }
    
    func publicKeys() -> Set<PublicKey> {
        return quark(type: AccountableQuark.self)
            .flatMap { $0.addresses }
            .flatMap { $0.map { $0.publicKey } }
            .map { Set($0) } ?? Set()
    }
}
