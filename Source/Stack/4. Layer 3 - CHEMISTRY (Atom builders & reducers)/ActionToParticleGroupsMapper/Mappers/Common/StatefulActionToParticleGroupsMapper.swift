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

public protocol BaseStatefulActionToParticleGroupsMapper {
    func requiredStateForAnAction(_ userAction: UserAction) -> [AnyShardedParticleStateId]
    
    // TODO replace`upParticles: [AnyUpParticle]` with `spunPartices: [AnySpunParticle]`, since for many Mappers we would like to look for RRIParticles with spin `.down` to see of an RRI is already in use
    func particleGroupsForAnAction(_ userAction: UserAction, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws -> ParticleGroups
}

public protocol StatefulActionToParticleGroupsMapper: BaseStatefulActionToParticleGroupsMapper {
    associatedtype Action: UserAction
    func requiredState(for action: Action) -> [AnyShardedParticleStateId]
    func validateInput(action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws
    func particleGroups(for action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws -> ParticleGroups
}

public extension StatefulActionToParticleGroupsMapper {
    func particleGroupsForAnAction(_ userAction: UserAction, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws -> ParticleGroups {

        // TODO throw error instead of fatalError?
        let action = castOrKill(instance: userAction, toType: Action.self)
        return try particleGroups(for: action, upParticles: upParticles, addressOfActiveAccount: addressOfActiveAccount)
    }
    
    func requiredStateForAnAction(_ userAction: UserAction) -> [AnyShardedParticleStateId] {
        // TODO throw error instead of fatalError?
        let action = castOrKill(instance: userAction, toType: Action.self)
        return requiredState(for: action)
    }
}
