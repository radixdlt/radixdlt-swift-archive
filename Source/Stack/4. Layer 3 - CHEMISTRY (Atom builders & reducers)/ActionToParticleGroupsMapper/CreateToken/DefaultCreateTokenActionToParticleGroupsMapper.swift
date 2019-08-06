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
    func particleGroups(for action: CreateTokenAction) -> ParticleGroups {

        switch action.tokenSupplyType {
        case .mutable: return mutableSupplyTokenParticleGroups(for: action)
        case .fixed: return fixedSupplyTokenParticleGroups(for: action)
        }
    }
}

private extension CreateTokenActionToParticleGroupsMapper {
    func mutableSupplyTokenParticleGroups(for action: CreateTokenAction) -> ParticleGroups {
        
        let mutableSupplyToken = MutableSupplyTokenDefinitionParticle(createTokenAction: action)
        let unallocated = UnallocatedTokensParticle.maxSupplyForNewToken(mutableSupplyToken: mutableSupplyToken)
        let rriParticle = ResourceIdentifierParticle(token: mutableSupplyToken)
        
        let tokenCreationGroup: ParticleGroup = [
            rriParticle.withSpin(.down),
            mutableSupplyToken.withSpin(.up),
            unallocated.withSpin(.up)
        ]
        
        let initialSupply = action.initialSupply
        guard let positiveInitialSupply = initialSupply.positiveAmount else {
            return [tokenCreationGroup]
        }
        
        guard let minted = try? TransferrableTokensParticle(mutableSupplyToken: mutableSupplyToken, amount: positiveInitialSupply) else {
            incorrectImplementation("Should not be able to init CreateTokenAction with non matching granularity and amount.")
        }
        
        var mintGroup: ParticleGroup = [
            unallocated.withSpin(.down),
            minted.withSpin(.up)
        ]
        
        if let positiveLeftOverSupply = initialSupply.subtractedFromMax {
            let unallocatedFromLeftOverSupply = UnallocatedTokensParticle(mutableSupplyToken: mutableSupplyToken, amount: positiveLeftOverSupply)
            mintGroup += unallocatedFromLeftOverSupply.withSpin(.up)
        }
        
        return [
            tokenCreationGroup,
            mintGroup
        ]
    }
    
    func fixedSupplyTokenParticleGroups(for action: CreateTokenAction) -> ParticleGroups {
        guard let amount = try? PositiveAmount(nonNegative: action.initialSupply.amount) else {
            incorrectImplementation("Amount should always be positive for FixedSupply")
        }
        
        let fixedSupplyToken = FixedSupplyTokenDefinitionParticle(createTokenAction: action)
        let rriParticle = ResourceIdentifierParticle(token: fixedSupplyToken)
     
        guard let tokens = try? TransferrableTokensParticle(fixedSupplyToken: fixedSupplyToken, amount: amount) else {
            incorrectImplementation("Should not be able to init CreateTokenAction with non matching granularity and amount.")
        }
        
        let tokenCreationGroup: ParticleGroup = [
            rriParticle.withSpin(.down),
            fixedSupplyToken.withSpin(.up),
            tokens.withSpin(.up)
        ]
    
        return [
            tokenCreationGroup
        ]
    }
}

// MARK: - TransferrableTokensParticle from TokenDefinitionParticles
private extension TransferrableTokensParticle {
    init(
        mutableSupplyToken token: MutableSupplyTokenDefinitionParticle,
        amount: PositiveAmount) throws {
        try self.init(
            amount: amount,
            address: token.address,
            tokenDefinitionReference: token.tokenDefinitionReference,
            permissions: token.permissions,
            granularity: token.granularity
        )
    }
    
    init(
        fixedSupplyToken token: FixedSupplyTokenDefinitionParticle,
        amount: PositiveAmount) throws {
        try self.init(
            amount: amount,
            address: token.address,
            tokenDefinitionReference: token.tokenDefinitionReference,
            permissions: nil,
            granularity: token.granularity
        )
    }
}
