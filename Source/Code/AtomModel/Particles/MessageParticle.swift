//
//  MessageParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// In Java library: "MetaDataMap"
public struct MetaData: Codable, Equatable, ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = String
    public let metaData: [Key: Value]
}

public extension MetaData {
    init(dictionaryLiteral nodes: (Key, Value)...) {
        self.init(metaData: Dictionary(uniqueKeysWithValues: nodes))
    }
}

public struct MessageParticle: ParticleConvertible {
    
    public let from: Address
    
    // MARK: ParticleConvertible properties
    public let quarks: Quarks
    
    public init(from: Address, addresses: Addresses, payload: Data, metaData: MetaData? = nil) {
        self.from = from
        self.quarks = [
            AccountableQuark(addresses: addresses),
            DataQuark(payload: payload, metaData: metaData)
        ]
    }
}

public extension MessageParticle {
    init(from: Address, to: Address, payload: Data, metaData: MetaData? = nil) {
        self.init(from: from, addresses: [from, to], payload: payload, metaData: metaData)
    }
}
