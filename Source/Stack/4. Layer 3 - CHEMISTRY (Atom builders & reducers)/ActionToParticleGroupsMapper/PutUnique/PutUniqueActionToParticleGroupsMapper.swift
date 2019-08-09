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

// MARK: PutUniqueActionToParticleGroupsMapper
public protocol PutUniqueActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper, Throwing where Action == PutUniqueIdAction, Error == PutUniqueIdError {}

public enum PutUniqueIdError: Swift.Error, Equatable {
    case uniqueIdAlreadyUsed(string: String)
    case rriAlreadyUsedByFixedSupplyToken(identifier: ResourceIdentifier)
    case rriAlreadyUsedByMutableSupplyToken(identifier: ResourceIdentifier)
    case nonMatchingAddress(activeAddress: Address, butActionStatesAddress: Address)
}

public extension PutUniqueActionToParticleGroupsMapper {
    
    // TODO When StatefulActionToParticleGroupsMapper uses `spunPartices: [AnySpunParticle]` instead of `upParticles: [AnyUpParticle]` we need only to look for RRIParticles with spin `.down`
    func requiredState(for putUniqueIdAction: PutUniqueIdAction) -> [AnyShardedParticleStateId] {
        let rriAddress = putUniqueIdAction.uniqueMaker

        return [
            // To verify that we haven't already used that RRI for UniqueId
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: UniqueParticle.self, address: rriAddress)
            ),
            
            // To verify that we haven't already used that RRI for MutableSupplyTokenDefinitionParticle
            AnyShardedParticleStateId(
                ShardedParticleStateId(
                    typeOfParticle: MutableSupplyTokenDefinitionParticle.self,
                    address: rriAddress
                )
            ),
            
            // To verify that we haven't already used that RRI for FixedSupplyTokenDefinitionParticle
            AnyShardedParticleStateId(
                ShardedParticleStateId(
                    typeOfParticle: FixedSupplyTokenDefinitionParticle.self,
                    address: rriAddress
                )
            )
        ]
    }
}

// MARK: DefaultPutUniqueActionToParticleGroupsMapper
public final class DefaultPutUniqueActionToParticleGroupsMapper: PutUniqueActionToParticleGroupsMapper { }

public extension DefaultPutUniqueActionToParticleGroupsMapper {
    typealias Action = PutUniqueIdAction

    func particleGroups(for action: PutUniqueIdAction, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws -> ParticleGroups {
        try validateInput(action: action, upParticles: upParticles, addressOfActiveAccount: addressOfActiveAccount)
        
        let uniqueParticle = UniqueParticle(address: action.uniqueMaker, string: action.string)
        let rriParticle = ResourceIdentifierParticle(resourceIdentifier: uniqueParticle.identifier)
        
        let spunParticles = [
            rriParticle.withSpin(.down),
            uniqueParticle.withSpin(.up)
        ]
        
        return [spunParticles.wrapInGroup()]
    }
}

private extension DefaultPutUniqueActionToParticleGroupsMapper {
    func validateInput(action: PutUniqueIdAction, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws {
        guard action.uniqueMaker == addressOfActiveAccount else {
            throw Error.nonMatchingAddress(activeAddress: addressOfActiveAccount, butActionStatesAddress: action.uniqueMaker)
        }
        
        let rri = action.identifier
        
        if upParticles.containsAnyUniqueParticle(matchingIdentifier: rri) {
            throw Error.uniqueIdAlreadyUsed(string: rri.name)
        }
        
        if upParticles.containsAnyMutableSupplyTokenDefinitionParticle(matchingIdentifier: rri) {
            throw Error.rriAlreadyUsedByMutableSupplyToken(identifier: rri)
        }
        
        if upParticles.containsAnyFixedSupplyTokenDefinitionParticle(matchingIdentifier: rri) {
            throw Error.rriAlreadyUsedByFixedSupplyToken(identifier: rri)
        }
        
        // All is well
    }
}
