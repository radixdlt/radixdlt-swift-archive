//
//  Particle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ParticleConvertible: Codable {
    var particleType: ParticleType { get }
    func shardables() -> Addresses
}

public extension ParticleConvertible where Self: RadixModelTypeStaticSpecifying {
    var particleType: ParticleType {
        do {
            return try ParticleType(modelType: type)
        } catch {
            incorrectImplementation("Error: \(error)")
        }
    }
}

public extension ParticleConvertible {

    func shardables() -> Addresses {
        var addresses = Set<Address>()
        
        if let accountable = self as? Accountable {
            addresses.insert(contentsOf: accountable.addresses)
        }
        
        if let identifiable = self as? Identifiable {
            addresses.insert(identifiable.identifier.address)
        }
        
        return Addresses(addresses: addresses)
    }
    
    func `as`<P>(_ type: P.Type) -> P? where P: ParticleConvertible {
        guard let specific = self as? P else {
            return nil
        }
        return specific
    }
}
