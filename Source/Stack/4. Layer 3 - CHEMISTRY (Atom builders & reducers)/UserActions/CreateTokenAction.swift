//
//  CreateTokenAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct CreateTokenAction: UserAction, Throwing, TokenConvertible {

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
        supply initialSupplyType: InitialSupply,
        granularity: Granularity = .default
    ) throws {
        
        switch initialSupplyType {
        case .fixed(let positiveInitialSupply):
            self.supplyType = .fixed
            self.initialSupply = NonNegativeAmount(positive: positiveInitialSupply)
        case .mutable(let nonNegativeInitialSupply):
            self.supplyType = .mutable
            self.initialSupply = nonNegativeInitialSupply
        }
        
        guard initialSupply.isExactMultipleOfGranularity(granularity) else {
            throw Error.initialSupplyNotMultipleOfGranularity
        }
        
        self.creator = creator
        self.name = name
        self.symbol = symbol
        self.description = description
        self.granularity = granularity
    }
}

public extension CreateTokenAction {
    enum Error: Swift.Error, Equatable {
        // swiftlint:disable:next identifier_name
        case initialSupplyNotMultipleOfGranularity
    }
}

// MARK: - TokenConvertible
public extension CreateTokenAction {
    var address: Address {
        return creator
    }
}

public extension CreateTokenAction {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: creator, symbol: symbol)
    }
}

public extension CreateTokenAction {
    enum InitialSupply {
        case fixed(to: PositiveAmount)
        case mutable(initial: NonNegativeAmount)
    }
    
    enum SupplyType: Int, Hashable {
        case fixed
        case mutable
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
