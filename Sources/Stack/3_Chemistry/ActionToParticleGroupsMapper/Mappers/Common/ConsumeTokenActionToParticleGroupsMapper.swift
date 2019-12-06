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
        typedTokenDefinition: TypedTokenDefinition
        ) throws
}

public extension ConsumeTokenActionToParticleGroupsMapper {
    
    func requiredState(for action: Action) -> [AnyShardedParticleStateId] {
        return AnyShardedParticleStateId.stateConsumingTokens(actor: action.user, tokenIdentifier: action.identifierForTokenToConsume)
    }
    
    func validateConsumeTokenAction(
        _ action: Action,
        typedTokenDefinition: TypedTokenDefinition
    ) throws {}
    
    func validateInput(action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws {
        guard action.user == addressOfActiveAccount else {
            throw ConsumeTokensActionError.nonMatchingAddress(activeAddress: addressOfActiveAccount, butActionStatesAddress: action.user)
        }
        
        let rri = action.identifierForTokenToConsume
        
        guard let typedTokenDefinition = upParticles.typedTokenDefinition(matchingIdentifier: rri) else {
            throw ConsumeTokensActionError.unknownToken(identifier: rri)
        }
        
        try validateConsumeTokenAction(action, typedTokenDefinition: typedTokenDefinition)

        let tokenDefinition = typedTokenDefinition.tokenDefinition
        
        guard action.amount.isMultiple(of: tokenDefinition.granularity) else {
            
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
