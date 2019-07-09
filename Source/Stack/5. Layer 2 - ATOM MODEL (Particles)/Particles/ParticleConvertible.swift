//
//  Particle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias PublicKeyHashEUID = HashEUID
public protocol DestinationsOwner {
    func destinations() -> [PublicKeyHashEUID]
}

/// An abstract type bundling together particles
public protocol ParticleConvertible: RadixHashable, DSONEncodable, Codable, DestinationsOwner {
    var particleType: ParticleType { get }
    
    func shardables() -> Addresses?
}

public extension DestinationsOwner where Self: Accountable {
    func destinations() -> [PublicKeyHashEUID] {
        return addresses.elements.map { $0.publicKey.hashEUID }.sorted()
    }
}

public extension ParticleConvertible {
    func shardables() -> Addresses? {

        guard let accountable = self as? Accountable else {
            return nil
        }
        
        return accountable.addresses
    }
}

public extension ParticleConvertible where Self: RadixModelTypeStaticSpecifying {
    var particleType: ParticleType {
        do {
            return try ParticleType(serializer: serializer)
        } catch {
            incorrectImplementation("Error: \(error)")
        }
    }
}

