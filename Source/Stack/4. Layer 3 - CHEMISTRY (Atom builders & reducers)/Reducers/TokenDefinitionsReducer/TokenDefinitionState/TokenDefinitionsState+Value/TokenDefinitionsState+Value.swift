//
//  TokenDefinitionsState+Value.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension TokenDefinitionsState {
    enum Value: TokenDefinitionReferencing, Equatable {
        case partial(Partial)
        case full(TokenState)
    }
}

public extension TokenDefinitionsState.Value {
    
    // MARK: From Protocols
    init(tokenConvertible: TokenConvertible) {
        self = .partial(.tokenDefinition(TokenDefinition(tokenConvertible: tokenConvertible)))
    }
    
    init(supplyState: TokenSupplyStateConvertible) {
        self = .partial(.supply(TokenDefinitionsState.SupplyInfo(tokenSupplyStateConvertible: supplyState)))
    }
    
    // MARK: - From Particles
    init(tokenDefinitionParticle: TokenDefinitionParticle) {
        self.init(tokenConvertible: tokenDefinitionParticle)
    }
    
    init(unallocatedTokensParticle: UnallocatedTokensParticle) {
        self = .partial(.supply(TokenDefinitionsState.SupplyInfo(unallocatedTokensParticle: unallocatedTokensParticle)))
    }
    
    // MARK: - TokenDefinitionReferencing
    var tokenDefinitionReference: ResourceIdentifier {
        switch self {
        case .full(let tokenState): return tokenState.tokenDefinitionReference
        case .partial(let partial): return partial.tokenDefinitionReference
        }
    }
    
    var full: TokenState? {
        guard case .full(let tokenState) = self else { return nil }
        return tokenState
    }
    
    func merging(with other: TokenDefinitionsState.Value) throws -> TokenDefinitionsState.Value {
        switch (self, other) {
            
        case (.partial(let selfPartial), .partial(let otherPartial)):
            return try selfPartial.merging(with: otherPartial)
            
        case (.full(let selfFull), .full(let otherFull)):
            return .full(try selfFull.merging(with: otherFull))
            
        case (.partial(let selfPartial), .full(let otherFull)):
            return .full(try otherFull.mergingWithPartial(selfPartial))
            
        case (.full(let selfFull), .partial(let otherPartial)):
            return .full(try selfFull.mergingWithPartial(otherPartial))
            
        }
    }
    
    var isFull: Bool {
        return full != nil
    }
    
    var isPartial: Bool {
        guard case .partial = self else { return false }
        return true
    }
}
