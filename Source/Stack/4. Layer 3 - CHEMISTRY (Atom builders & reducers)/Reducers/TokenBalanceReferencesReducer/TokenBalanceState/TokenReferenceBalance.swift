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

public struct TokenReferenceBalance: Equatable, Throwing {
    let tokenResourceIdentifier: ResourceIdentifier
    let amount: NonNegativeAmount
    let owner: Address
    
    public init(
        tokenResourceIdentifier: ResourceIdentifier,
        amount: NonNegativeAmount,
        owner: Address
        ) {
        self.tokenResourceIdentifier = tokenResourceIdentifier
        self.amount = amount
        self.owner = owner
    }
}

public extension TokenReferenceBalance {
    
    init(upTransferrableTokensParticle upParticle: UpParticle<TransferrableTokensParticle>) {
        
        let particle = upParticle.particle
        
        self.init(
            tokenResourceIdentifier: particle.tokenDefinitionReference,
            amount: particle.amount,
            owner: particle.address
        )
    }
    
    init(
        upTransferrableTokensParticles: [UpParticle<TransferrableTokensParticle>],
        tokenIdentifier: ResourceIdentifier,
        owner: Address
    ) throws {
        
        let tokenConsumables = upTransferrableTokensParticles.map { $0.particle }
        
        if tokenConsumables.contains(where: { $0.tokenDefinitionReference != tokenIdentifier }) {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        if tokenConsumables.contains(where: { $0.address != owner }) {
            throw Error.addressMismatch
        }
        
        let amount: NonNegativeAmount = tokenConsumables.map({ $0.amount }).reduce(NonNegativeAmount.zero) { $0 + $1 }
        
        self.init(tokenResourceIdentifier: tokenIdentifier, amount: amount, owner: owner)
    }
    
    enum Error: Swift.Error, Equatable {
        case addressMismatch
        case tokenDefinitionReferenceMismatch
    }
    
    func merging(with other: TokenReferenceBalance) throws -> TokenReferenceBalance {
        
        if other.tokenResourceIdentifier != tokenResourceIdentifier {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        if other.owner != self.owner {
            throw Error.addressMismatch
        }
        
        return TokenReferenceBalance(
            tokenResourceIdentifier: tokenResourceIdentifier,
            amount: amount + other.amount,
            owner: owner
        )
    }
}
