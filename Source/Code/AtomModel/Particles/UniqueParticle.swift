//
//  UniqueParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct UniqueParticle: ParticleConvertible {
    
    public let type: ParticleTypes = .unique
    
    public let address: Address
    public let name: Name
    
    public init(address: Address, uniqueName name: Name) {
        self.address = address
        self.name = name
    }
}

public extension UniqueParticle {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: address, type: .unique, name: name)
    }
}
