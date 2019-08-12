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

public protocol UniquelyIdentifiedActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper {}

public extension UniquelyIdentifiedActionToParticleGroupsMapper {
    func requiredState(for action: Action) -> [AnyShardedParticleStateId] {
        return AnyShardedParticleStateId.stateForUniqueIdentifier(address: action.user)
    }
}

public extension UniquelyIdentifiedActionToParticleGroupsMapper where Action: UniquelyIdentifiedAction {
    func validateInput(action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws {
        guard action.user == addressOfActiveAccount else {
            throw UniquelyIdentifiedActionError.nonMatchingAddress(activeAddress: addressOfActiveAccount, butActionStatesAddress: action.user)
        }
        
        let rri = action.identifier
        
        if upParticles.containsAnyUniqueParticle(matchingIdentifier: rri) {
            throw UniquelyIdentifiedActionError.rriAlreadyUsedByUniqueId(string: rri.name)
        }
        
        if upParticles.containsAnyMutableSupplyTokenDefinitionParticle(matchingIdentifier: rri) {
            throw UniquelyIdentifiedActionError.rriAlreadyUsedByMutableSupplyToken(identifier: rri)
        }
        
        if upParticles.containsAnyFixedSupplyTokenDefinitionParticle(matchingIdentifier: rri) {
            throw UniquelyIdentifiedActionError.rriAlreadyUsedByFixedSupplyToken(identifier: rri)
        }
        
        // All is well
    }
}

public extension UniquelyIdentifiedActionToParticleGroupsMapper where Action: UniquelyIdentifiedAction, Self: Throwing, Error: UniqueActionErrorInitializable {
    func validateInputMappingUniqueActionError(action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws {
        do {
            try validateInput(action: action, upParticles: upParticles, addressOfActiveAccount: addressOfActiveAccount)
        } catch let uniqueActionError as UniquelyIdentifiedActionError {
            throw Error.errorFrom(uniqueActionError: uniqueActionError)
        } catch { throw error }
    }    
}
