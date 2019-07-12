//
//  TokenDefinitionsState+SupplyInfo.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension TokenDefinitionsState {
    struct SupplyInfo: TokenSupplyStateConvertible, Equatable {
        public let totalSupply: Supply
        public let tokenDefinitionReference: ResourceIdentifier
    }
}

public extension TokenDefinitionsState.SupplyInfo {
    init(tokenSupplyStateConvertible: TokenSupplyStateConvertible) {
        self.init(
            totalSupply: tokenSupplyStateConvertible.totalSupply,
            tokenDefinitionReference: tokenSupplyStateConvertible.tokenDefinitionReference
        )
    }
    
    init(unallocatedTokensParticle: UnallocatedTokensParticle) {
        self.init(
            totalSupply: Supply(unallocatedTokensParticle: unallocatedTokensParticle),
            tokenDefinitionReference: unallocatedTokensParticle.tokenDefinitionReference
        )
    }
}
