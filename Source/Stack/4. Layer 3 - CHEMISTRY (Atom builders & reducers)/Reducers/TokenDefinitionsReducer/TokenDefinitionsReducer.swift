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

public final class TokenDefinitionsReducer: ParticleReducer {}

public extension TokenDefinitionsReducer {
    
    typealias State = TokenDefinitionsState

    var initialState: TokenDefinitionsState {
        return TokenDefinitionsState()
    }
    
    func reduce(state currentState: State, upParticle: AnyUpParticle) throws -> State {

        let particle = upParticle.particle

        if let tokenConvertible = particle as? TokenConvertible {
            return currentState.mergingWithNewTokenDefinition(tokenConvertible)
        } else if let unallocatedTokensParticle = particle as? UnallocatedTokensParticle {
            return try currentState.mergingWithUnallocatedTokensParticle(unallocatedTokensParticle)
        } else {
            return currentState
        }
    }

}

private extension TokenDefinitionsState {
    func mergingWithNewTokenDefinition(_ tokenConvertible: TokenConvertible) -> TokenDefinitionsState {
        let rri = tokenConvertible.tokenDefinitionReference
        let newTokenDefinition = TokenDefinition(tokenConvertible: tokenConvertible)
        
        guard let existingValue = valueFor(identifier: rri) else {
            return setting(value: .justToken(newTokenDefinition))
        }
        
        if let supply = existingValue.supply {
            return setting(value: .full(TokenState(token: newTokenDefinition, supply: supply)))
        } else {
            return setting(value: .justToken(newTokenDefinition))
        }
    }
    
    func mergingWithUnallocatedTokensParticle(_ unallocatedTokensParticle: UnallocatedTokensParticle) throws -> TokenDefinitionsState {
        let rri = unallocatedTokensParticle.tokenDefinitionReference
        
        guard let existingValue = valueFor(identifier: rri) else {
            return setting(value:
                .justUnallocated(
                    amount: try Supply(subtractingFromMax: unallocatedTokensParticle.amount.amount),
                    tokenDefinitionReference: rri
                )
            )
        }

        switch existingValue {
        case .full(let existingFull):
            return setting(value:
                .full(try existingFull.reducingSupply(by: unallocatedTokensParticle.amount))
            )
        case .justToken(let token):
            let supply = try Supply(subtractingFromMax: unallocatedTokensParticle.amount.amount)
            return setting(value: .full(TokenState(token: token, supply: supply)))
        case .justUnallocated(let existingSupply, _):
            let supply = try existingSupply.subtracting(unallocatedTokensParticle.amount)
            return setting(value: .justUnallocated(amount: supply, tokenDefinitionReference: rri))
        }
        
    }
    
    func setting(value: Value) -> TokenDefinitionsState {
        let rri = value.tokenDefinitionReference
        var mutableCopy = self
        mutableCopy.dictionary[rri] = value
        return mutableCopy
    }
}

private extension TokenDefinitionsState.Value {
    var supply: Supply? {
        switch self {
        case .full(let tokenState): return tokenState.totalSupply
        case .justUnallocated(let supply, _): return supply
        case .justToken: return nil
        }
    }
}

private extension TokenState {
    func updatingSupply(to newSupply: Supply) -> TokenState {
        return TokenState(token: self, supply: newSupply)
    }
    
    func reducingSupply(by supplyToSubtract: Supply) throws -> TokenState {
        let newSupply = try totalSupply.subtracting(supplyToSubtract)
        return updatingSupply(to: newSupply)
        
    }
}
