//
//  TokenState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-10.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias TokenStateConvertible = TokenConvertible & TokenSupplyStateConvertible

// swiftlint:disable colon opening_brace

public struct TokenState:
    TokenStateConvertible,
    Throwing,
    Hashable
{
    // swiftlint:enable colon opening_brace
    
    // MARK: - Properties
    public let totalSupply: Supply
    public let tokenSupplyType: SupplyType
    
    // MARK: TokenConvertible Properties
    public let symbol: Symbol
    public let name: Name
    public let tokenDefinedBy: Address
    public let description: Description
    public let granularity: Granularity
    
    private init(
        totalSupply: Supply,
        tokenSupplyType: SupplyType,
        symbol: Symbol,
        name: Name,
        tokenDefinedBy: Address,
        description: Description,
        granularity: Granularity
    ) {
        self.totalSupply = totalSupply
        self.tokenSupplyType = tokenSupplyType
        
        self.symbol = symbol
        self.name = name
        self.tokenDefinedBy = tokenDefinedBy
        self.description = description
        self.granularity = granularity
    }
}

// MARK: - Convenience Initializers

// MARK: Private Init
private extension TokenState {
    init(
        token tokenDefinition: TokenConvertible,
        totalSupply: Supply
    ) {
        
        self.init(
            totalSupply: totalSupply,
            tokenSupplyType: tokenDefinition.tokenSupplyType,
            symbol: tokenDefinition.symbol,
            name: tokenDefinition.name,
            tokenDefinedBy: tokenDefinition.tokenDefinedBy,
            description: tokenDefinition.description,
            granularity: tokenDefinition.granularity
        )
    }
}

// MARK: Public Init
public extension TokenState {

    init(
        token tokenDefinition: TokenConvertible,
        supplyState: TokenSupplyStateConvertible
    ) throws {
        
        guard tokenDefinition.tokenDefinitionReference == supplyState.tokenDefinitionReference else {
            throw Error.tokenDefinitionReferenceMismatch
        }
        self.init(
            token: tokenDefinition,
            totalSupply: supplyState.totalSupply
        )
    }
    
    init(tokenStateConvertible: TokenStateConvertible) {
        self.init(
            token: tokenStateConvertible,
            totalSupply: tokenStateConvertible.totalSupply
        )
    }
}

// MARK: - Throwing
public extension TokenState {
    enum Error: Swift.Error, Equatable {
        case tokenDefinitionReferenceMismatch
    }
}

// MARK: - Merge
public extension TokenState {
    func merging(with other: TokenState) throws -> TokenState {

        if other.tokenDefinitionReference != tokenDefinitionReference {
            throw Error.tokenDefinitionReferenceMismatch
        }

        let updatedTotalSupply = try self.totalSupply.add(other.totalSupply)

        return TokenState(
            token: other,
            totalSupply: updatedTotalSupply
        )
    }

    func mergingWithPartial(_ partial: TokenDefinitionsState.Value.Partial) throws -> TokenState {
        guard partial.tokenDefinitionReference == self.tokenDefinitionReference else {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        switch partial {
        case .supply(let supplyInfo):
            return try TokenState(token: self, supplyState: supplyInfo)
        case .tokenDefinition(let tokenDefinition):
            return TokenState(
                token: tokenDefinition,
                totalSupply: self.totalSupply
            )
        }
    }
}
