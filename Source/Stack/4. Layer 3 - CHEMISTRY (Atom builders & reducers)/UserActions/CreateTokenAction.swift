//
//  CreateTokenAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct CreateTokenAction: UserAction {

    public let creator: Address
    public let name: Name
    public let symbol: Symbol
    public let description: Description
    public let granularity: Granularity
    public let initialSupply: NonNegativeAmount
    public let supplyType: SupplyType
    
    public init(
        creator: Address,
        name: Name,
        symbol: Symbol,
        description: Description,
        supplyType: SupplyType,
        initialSupply: NonNegativeAmount = .zero,
        granularity: Granularity = .default
    ) {
        self.creator = creator
        self.name = name
        self.symbol = symbol
        self.description = description
        self.supplyType = supplyType
        self.initialSupply = initialSupply
        self.granularity = granularity
    }
}

public extension CreateTokenAction {
    enum SupplyType: Int, Equatable {
        case fixed, mutable
    }
}

public extension CreateTokenAction.SupplyType {
    var tokenPermissions: TokenPermissions {
        switch self {
        case .fixed: return [.mint: .tokenCreationOnly, .burn: .none]
        case .mutable: return [.mint: .tokenOwnerOnly, .burn: .tokenOwnerOnly]
        }
    }
}
