//
//  TokenDefinitionParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenDefinitionParticle: ParticleModelConvertible, Identifiable {
    
    public static let type = RadixModelType.tokenDefinitionParticle
    
    public let symbol: Symbol
    public let name: Name
    public let description: Description
    public let address: Address
    public let metaData: MetaData
    public let granularity: Granularity
    public let permissions: TokenPermissions
    
    public init(
        symbol: Symbol,
        name: Name,
        description: Description,
        address: Address,
        metaData: MetaData = [:],
        granularity: Granularity = .default,
        permissions: TokenPermissions
    ) {
        self.symbol = symbol
        self.name = name
        self.description = description
        self.address = address
        self.metaData = metaData
        self.granularity = granularity
        self.permissions = permissions
    }
}
