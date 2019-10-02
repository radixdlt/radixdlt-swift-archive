//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public final class DefaultCreateTokenActionToParticleGroupsMapper: CreateTokenActionToParticleGroupsMapper {}

public extension CreateTokenActionToParticleGroupsMapper {
    
    func particleGroups(for action: CreateTokenAction, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws -> ParticleGroups {
        
        try validateInputMappingUniqueActionError(action: action, upParticles: upParticles, addressOfActiveAccount: addressOfActiveAccount)
        
        switch action.tokenSupplyType {
        case .mutable: return try mutableSupplyTokenParticleGroups(for: action)
        case .fixed: return try fixedSupplyTokenParticleGroups(for: action)
        }
    }
}

private extension CreateTokenActionToParticleGroupsMapper {
    
    func initialSupplyDefinitionFrom(action: CreateTokenAction) throws -> CreateTokenAction.InitialSupply.SupplyTypeDefinition {
        guard let supplyDefinition = action.supplyDefinition else {
            throw Error.createTokenActionContainsDerivedSupplyWhichIsNotSupported
        }
        return supplyDefinition
    }
    
    func mutableSupplyTokenParticleGroups(for action: CreateTokenAction) throws -> ParticleGroups {
        let initialSupplyDefinition = try initialSupplyDefinitionFrom(action: action)
        
        let mutableSupplyToken = try MutableSupplyTokenDefinitionParticle(createTokenAction: action)
        let unallocated = UnallocatedTokensParticle.maxSupplyForNewToken(mutableSupplyTokenDefinitionParticle: mutableSupplyToken)
        let rriParticle = ResourceIdentifierParticle(token: mutableSupplyToken)
        
        let tokenCreationGroup: ParticleGroup = [
            rriParticle.withSpin(.down),
            mutableSupplyToken.withSpin(.up),
            unallocated.withSpin(.up)
        ]
        
        let initialSupply = initialSupplyDefinition.initialSupply
        guard let positiveInitialSupplyAmount = try? PositiveAmount(unrelated: initialSupply) else {
            return [tokenCreationGroup]
        }
        
        guard let minted = try? TransferrableTokensParticle(mutableSupplyTokenDefinitionParticle: mutableSupplyToken, amount: positiveInitialSupplyAmount) else {
            incorrectImplementation("Should not be able to init CreateTokenAction with non matching granularity and amount.")
        }
        
        var mintGroup: ParticleGroup = [
            unallocated.withSpin(.down),
            minted.withSpin(.up)
        ]
        
        let positiveInitialSupply = PositiveSupply(other: positiveInitialSupplyAmount)
        if let positiveLeftOverSupply = try? PositiveSupply(subtractedFromMax: positiveInitialSupply) {
            
            let unallocatedFromLeftOverSupply = UnallocatedTokensParticle(
                mutableSupplyTokenDefinitionParticle: mutableSupplyToken,
                positiveSupply: positiveLeftOverSupply
            )
            
            try mintGroup += unallocatedFromLeftOverSupply.withSpin(.up)
            
        }
        
        return try ParticleGroups(particleGroups: [
            tokenCreationGroup,
            mintGroup
        ])
    }
    
    func fixedSupplyTokenParticleGroups(for action: CreateTokenAction) throws -> ParticleGroups {
        let initialSupplyDefinition = try initialSupplyDefinitionFrom(action: action)
        
        let positiveSupply = try PositiveSupply(related: initialSupplyDefinition.initialSupply)
        
        let fixedSupplyToken = FixedSupplyTokenDefinitionParticle(createTokenAction: action, positiveSupply: positiveSupply)
        let rriParticle = ResourceIdentifierParticle(token: fixedSupplyToken)
     
        let transferrableTokensParticle = try TransferrableTokensParticle(fixedSupplyTokenDefinitionParticle: fixedSupplyToken, positiveSupply: positiveSupply)
        
        let tokenCreationGroup: ParticleGroup = [
            rriParticle.withSpin(.down),
            fixedSupplyToken.withSpin(.up),
            transferrableTokensParticle.withSpin(.up)
        ]
    
        return [
            tokenCreationGroup
        ]
    }
}

