//
//  MessageParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct MessageParticle: ParticleConvertible, Accountable {
    
    public let from: Address
    public let to: Address
    public let metaData: MetaData
    public let payload: Data
    
    public init(from: Address, to: Address, payload: Data, metaData: MetaData = [:]) {
        self.from = from
        self.to = to
        self.metaData = metaData
        self.payload = payload
    }
}

// MARK: - Accountable
public extension MessageParticle {
    var addresses: Addresses {
        return Addresses([from, to])
    }
}
