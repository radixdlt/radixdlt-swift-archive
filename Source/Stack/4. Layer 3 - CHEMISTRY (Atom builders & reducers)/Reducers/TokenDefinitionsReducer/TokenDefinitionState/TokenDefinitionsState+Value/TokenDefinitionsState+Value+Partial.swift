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
    func merging(with other: TokenDefinitionsState.Value.Partial) throws -> TokenDefinitionsState.Value {
        guard self.tokenDefinitionReference == other.tokenDefinitionReference else {
            throw TokenDefinitionsState.Error.tokenDefinitionReferenceMismatch
        }
        
        switch (self, other) {
        case (.supply(_), .supply(let otherSupplyInfo)):
            let totalSupply = otherSupplyInfo.totalSupply // TODO or should we add them????
            
            let mergedSupplyInfo = TokenDefinitionsState.SupplyInfo(
                totalSupply: totalSupply,
                tokenDefinitionReference: tokenDefinitionReference
            )
            
            return .partial(.supply(mergedSupplyInfo))
            
        case (.tokenDefinition(let selfTokenDefinition), .supply(let otherSupplyInfo)):
            return .full(try TokenState(token: selfTokenDefinition, supplyState: otherSupplyInfo))
            
        case (.supply(let selfSupplyInfo), .tokenDefinition(let otherTokenDefinition)):
            return .full(try TokenState(token: otherTokenDefinition, supplyState: selfSupplyInfo))
            
        case (.tokenDefinition(_), .tokenDefinition(let otherTokenDefinition)):
            return .partial(.tokenDefinition(otherTokenDefinition))
        }
    }
}
