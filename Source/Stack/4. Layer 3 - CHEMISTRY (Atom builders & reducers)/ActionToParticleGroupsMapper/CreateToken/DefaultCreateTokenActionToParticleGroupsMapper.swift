/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

public final class DefaultCreateTokenActionToParticleGroupsMapper: CreateTokenActionToParticleGroupsMapper {}

public extension CreateTokenActionToParticleGroupsMapper {
    func particleGroups(for action: CreateTokenAction) -> ParticleGroups {

        let token = TokenDefinitionParticle(createTokenAction: action)
        let unallocated = UnallocatedTokensParticle.maxSupplyForNewToken(token)
        let rriParticle = ResourceIdentifierParticle(token: token)
        
        let tokenCreationGroup: ParticleGroup = [
            rriParticle.withSpin(.down),
            token.withSpin(.up),
            unallocated.withSpin(.up)
        ]

        let initialSupply = action.initialSupply
        guard let positiveInitialSupply = initialSupply.positiveAmount else {
            return [tokenCreationGroup]
        }
        
        let amount = NonNegativeAmount(positive: positiveInitialSupply)
        let minted = TransferrableTokensParticle(token: token, amount: amount)
        
        var mintGroup: ParticleGroup = [
            unallocated.withSpin(.down),
            minted.withSpin(.up)
        ]
        
        if let positiveLeftOverSupply = initialSupply.subtractedFromMax {
            let unallocatedFromLeftOverSupply = UnallocatedTokensParticle(token: token, amount: positiveLeftOverSupply)
            mintGroup += unallocatedFromLeftOverSupply.withSpin(.up)
        }
        
        return [
            tokenCreationGroup,
            mintGroup
        ]
    }
}
