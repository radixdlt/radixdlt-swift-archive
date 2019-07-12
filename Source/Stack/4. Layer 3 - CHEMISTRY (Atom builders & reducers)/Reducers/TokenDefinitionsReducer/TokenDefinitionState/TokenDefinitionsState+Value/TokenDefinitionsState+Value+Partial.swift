//
//  TokenDefinitionsState+Value+Partial.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension TokenDefinitionsState.Value {
    enum Partial: TokenDefinitionReferencing, Equatable {
        case supply(TokenDefinitionsState.SupplyInfo)
        case tokenDefinition(TokenDefinition)
    }
}

// MARK: - TokenDefinitionReferencing
public extension TokenDefinitionsState.Value.Partial {
    var tokenDefinitionReference: ResourceIdentifier {
        switch self {
        case .supply(let supplyState): return supplyState.tokenDefinitionReference
        case .tokenDefinition(let tokenDefintion): return tokenDefintion.tokenDefinitionReference
        }
    }
}

// MARK: - Internal
internal extension TokenDefinitionsState.Value.Partial {
    func merging(with newPartial: TokenDefinitionsState.Value.Partial) throws -> TokenDefinitionsState.Value {
        guard self.tokenDefinitionReference == newPartial.tokenDefinitionReference else {
            throw TokenDefinitionsState.Error.tokenDefinitionReferenceMismatch
        }
        
        switch (self, newPartial) {
        case (.tokenDefinition(let currentTokenDefinition), .supply(let newSupplyInfo)):
            return .full(
                try TokenState(
                    token: currentTokenDefinition,
                    supplyState: newSupplyInfo
                )
            )
            
        case (.supply(let currentSupplyInfo), .tokenDefinition(let newTokenDefinition)):
            return .full(
                try TokenState(
                    token: newTokenDefinition,
                    supplyState: currentSupplyInfo
                )
            )
            
        case (.supply(let currentSupplyInfo), .supply(let newSupplyInfo)):
            let accumulatedSupply = try currentSupplyInfo.totalSupply.add(newSupplyInfo.totalSupply)
            
            let accumulatedSupplyInfo = TokenDefinitionsState.SupplyInfo(
                totalSupply: accumulatedSupply,
                tokenDefinitionReference: tokenDefinitionReference
            )
            
            return .partial(.supply(accumulatedSupplyInfo))
            
        case (.tokenDefinition, .tokenDefinition(let newTokenDefinition)):
            return .partial(.tokenDefinition(newTokenDefinition))
        }
    }
}
