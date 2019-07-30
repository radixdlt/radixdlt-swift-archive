//
//  CreateTokenAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct CreateTokenAction: UserAction, Throwing, TokenConvertible, TokenSupplyStateConvertible {

    public let creator: Address
    public let name: Name
    public let symbol: Symbol
    public let description: Description
    public let granularity: Granularity
    public let initialSupply: Supply
    public let tokenSupplyType: SupplyType
    public let iconUrl: URL?
    
    public init(
        creator: Address,
        name: Name,
        symbol: Symbol,
        description: Description,
        supply initialSupplyType: InitialSupply,
        granularity: Granularity = .default,
        iconUrl: URL? = nil
    ) throws {

        switch initialSupplyType {
        case .fixed(let positiveInitialSupply):
            self.tokenSupplyType = .fixed
            self.initialSupply = positiveInitialSupply
        case .mutable(let nonNegativeInitialSupply):
            self.tokenSupplyType = .mutable
            self.initialSupply = nonNegativeInitialSupply ?? .zero
        }
        
        guard initialSupply.isExactMultipleOfGranularity(granularity) else {
            throw Error.initialSupplyNotMultipleOfGranularity
        }
        
        self.creator = creator
        self.name = name
        self.symbol = symbol
        self.description = description
        self.granularity = granularity
        self.iconUrl = iconUrl
    }
}

public extension CreateTokenAction {
    var nameOfAction: UserActionName { return .createToken }
}

// MARK: - Throwing
public extension CreateTokenAction {
    enum Error: Swift.Error, Equatable {
        case initialSupplyNotMultipleOfGranularity
    }
}

// MARK: - TokenConvertible
public extension CreateTokenAction {
    var tokenDefinedBy: Address {
        return creator
    }
}

// MARK: - TokenSupplyStateConvertible
public extension CreateTokenAction {
    var totalSupply: Supply {
        return initialSupply
    }
}

public extension CreateTokenAction {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: creator, symbol: symbol)
    }
}

public extension CreateTokenAction {
    
    enum InitialSupply {
        case fixed(to: Supply)
        case mutable(initial: Supply?)
    }
}
