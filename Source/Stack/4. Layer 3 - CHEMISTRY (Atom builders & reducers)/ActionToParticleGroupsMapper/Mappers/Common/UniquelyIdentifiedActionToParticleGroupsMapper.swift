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

public protocol UniquelyIdentifiedUserActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper {}

public extension UniquelyIdentifiedUserActionToParticleGroupsMapper {
    func requiredState(for action: Action) -> [AnyShardedParticleStateId] {
        return AnyShardedParticleStateId.stateForUniqueIdentifier(address: action.user)
    }
}

public extension UniquelyIdentifiedUserActionToParticleGroupsMapper where Action: UniquelyIdentifiedUserAction {
    func validateInput(action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws {
        guard action.user == addressOfActiveAccount else {
            throw UniquelyIdentifiedUserActionError.nonMatchingAddress(activeAddress: addressOfActiveAccount, butActionStatesAddress: action.user)
        }
        
        let rri = action.identifier
        
        if upParticles.containsAnyUniqueParticle(matchingIdentifier: rri) {
            throw UniquelyIdentifiedUserActionError.rriAlreadyUsedByUniqueId(string: rri.name)
        }
        
        if upParticles.containsAnyMutableSupplyTokenDefinitionParticle(matchingIdentifier: rri) {
            throw UniquelyIdentifiedUserActionError.rriAlreadyUsedByMutableSupplyToken(identifier: rri)
        }
        
        if upParticles.containsAnyFixedSupplyTokenDefinitionParticle(matchingIdentifier: rri) {
            throw UniquelyIdentifiedUserActionError.rriAlreadyUsedByFixedSupplyToken(identifier: rri)
        }
        
        // All is well
    }
}

public extension UniquelyIdentifiedUserActionToParticleGroupsMapper where Action: UniquelyIdentifiedUserAction, Self: Throwing, Error: UniqueActionErrorInitializable {
    func validateInputMappingUniqueActionError(action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws {
        do {
            try validateInput(action: action, upParticles: upParticles, addressOfActiveAccount: addressOfActiveAccount)
        } catch let uniqueActionError as UniquelyIdentifiedUserActionError {
            throw Error.errorFrom(uniqueActionError: uniqueActionError)
        } catch { throw error }
    }    
}
