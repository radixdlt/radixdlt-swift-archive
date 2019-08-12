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

public protocol ConsumeTokenActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper where Action: ConsumeTokensAction {
    func validateConsumeTokenAction(
        _ action: Action,
        consumeTokensContext: ConsumeTokensContext
        ) throws
}

public extension ConsumeTokenActionToParticleGroupsMapper {
    
    func requiredState(for action: Action) -> [AnyShardedParticleStateId] {
        return AnyShardedParticleStateId.stateConsumingTokens(actor: action.user, tokenIdentifier: action.identifierForTokenToConsume)
    }
    
    func validateConsumeTokenAction(
        _ action: Action,
        consumeTokensContext: ConsumeTokensContext
        ) throws {}
    
    func validateInput(action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws {
        guard action.user == addressOfActiveAccount else {
            throw ConsumeTokensActionError.nonMatchingAddress(activeAddress: addressOfActiveAccount, butActionStatesAddress: action.user)
        }
        
        let rri = action.identifierForTokenToConsume
        
        let maybeMutableSupplyTokenDefinitionParticle = upParticles.firstMutableSupplyTokenDefinitionParticle(matchingIdentifier: rri)
        let maybeFixedSupplyTokenDefinitionsParticle = upParticles.firstFixedSupplyTokenDefinitionParticle(matchingIdentifier: rri)
        
        let tokenDefinition: TokenConvertible
        switch (maybeMutableSupplyTokenDefinitionParticle, maybeFixedSupplyTokenDefinitionsParticle) {
        case (.some(let mutableSupplyTokenDefinitionParticle), .none):
            try validateConsumeTokenAction(action, consumeTokensContext: .mutableSupplyTokenDefinitionParticle(mutableSupplyTokenDefinitionParticle))
            tokenDefinition = mutableSupplyTokenDefinitionParticle
        case (.none, .some(let fixedSupplyTokenDefinitionsParticle)):
            try validateConsumeTokenAction(action, consumeTokensContext: .fixedSupplyTokenDefinitionParticle(fixedSupplyTokenDefinitionsParticle))
            tokenDefinition = fixedSupplyTokenDefinitionsParticle
        case (.none, .none):
            throw ConsumeTokensActionError.unknownToken(identifier: rri)
        case (.some, .some):
            incorrectImplementation("Not possible to have both a FixedSupplyTokenDefinition and a MutableSuppleTokenDefinition for the same RRI: \(rri)")
        }
        
        guard action.amount.isExactMultipleOfGranularity(tokenDefinition.granularity) else {
            
            throw ConsumeTokensActionError.amountNotMultipleOfGranularity(
                token: rri,
                triedToConsumeAmount: action.amount,
                whichIsNotMultipleOfGranularity: tokenDefinition.granularity
            )
        }
        
        // All is well
    }
}

public extension ConsumeTokenActionToParticleGroupsMapper where Self: Throwing, Error: ConsumeTokensActionErrorInitializable {
    func validateInputMappingConsumeTokensActionError(action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws {
        do {
            try validateInput(action: action, upParticles: upParticles, addressOfActiveAccount: addressOfActiveAccount)
        } catch let consumeTokensActionError as ConsumeTokensActionError {
            throw Error.errorFrom(consumeTokensActionError: consumeTokensActionError)
        } catch { throw error }
    }
}
