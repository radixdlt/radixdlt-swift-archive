//
//  Token.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenDefinition: TokenConvertible, Hashable {
    public let symbol: Symbol
    public let name: Name
    public let tokenDefinedBy: Address
    public let granularity: Granularity
    public let description: Description
    public let tokenSupplyType: SupplyType
    
    public init(
        symbol: Symbol,
        name: Name,
        tokenDefinedBy: Address,
        granularity: Granularity,
        description: Description,
        tokenSupplyType: SupplyType
    ) {
        self.name = name
        self.symbol = symbol
        self.granularity = granularity
        self.tokenDefinedBy = tokenDefinedBy
        self.description = description
        self.tokenSupplyType = tokenSupplyType
    }
}

public extension TokenDefinition {
    init(tokenConvertible token: TokenConvertible) {
        self.init(
            symbol: token.symbol,
            name: token.name,
            tokenDefinedBy: token.tokenDefinedBy,
            granularity: token.granularity,
            description: token.description,
            tokenSupplyType: token.tokenSupplyType
        )
    }
    
    init(particle: TokenDefinitionParticle) {
        self.init(tokenConvertible: particle)
    }
}
