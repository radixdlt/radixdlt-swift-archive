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

public struct TokenDefinitionsReducer: ParticleReducer {
    public let initialState = TokenDefinitionsState()
}

public extension TokenDefinitionsReducer {
    
    typealias State = TokenDefinitionsState
    
    func reduce(state currentState: State, upParticle: AnyUpParticle) throws -> State {

        let particle = upParticle.someParticle

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
        let newTokenDefinition = TokenDefinition(tokenConvertible: tokenConvertible)
        
        if let existingValue = valueFor(identifier: tokenConvertible.tokenDefinitionReference), let supply = existingValue.supply {
            return setting(value: .full(TokenState(token: newTokenDefinition, supply: supply)))
        } else {
            return setting(value: .justToken(newTokenDefinition))
        }
    }
    
    func mergingWithUnallocatedTokensParticle(_ unallocatedTokensParticle: UnallocatedTokensParticle) throws -> TokenDefinitionsState {
        let rri = unallocatedTokensParticle.tokenDefinitionReference
        
        let existingValue = valueFor(identifier: rri)
        let existingSupplyOrMax = existingValue?.supply ?? Supply.max
        let updatedSupply = try existingSupplyOrMax.subtracting(unallocatedTokensParticle.amount)
        
        switch existingValue {
        case .none, .some(.justSupply):
            return setting(value: .justSupply(updatedSupply, forToken: rri))
        case .some(.full(let token as TokenConvertible)), .some(.justToken(let token as TokenConvertible)):
            return setting(value: .full(TokenState(token: token, supply: updatedSupply)))
        }
    }
    
    func setting(value: Value) -> TokenDefinitionsState {
        let rri = value.tokenDefinitionReference
        var mutableCopy = self
        mutableCopy.dictionary[rri] = value
        return mutableCopy
    }
}
