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

public struct AnyStatelessActionToParticleGroupsMapper: BaseStatelessActionToParticleGroupsMapper {
    
    private let _actionType: () -> UserAction.Type
    private let _matchesType: (UserAction.Type) -> Bool
    private let _particleGroupsForAnAction: (UserAction, Address) throws -> ParticleGroups
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: StatelessActionToParticleGroupsMapper {
        self._actionType = { Concrete.Action.self }
        self._matchesType = { return $0 == Concrete.Action.self }
        
        self._particleGroupsForAnAction = { try concrete.particleGroupsForAnAction($0, addressOfActiveAccount: $1) }
    }
}

public extension AnyStatelessActionToParticleGroupsMapper {
    func particleGroupsForAnAction(_ userAction: UserAction, addressOfActiveAccount: Address) throws -> ParticleGroups {
        return try self._particleGroupsForAnAction(userAction, addressOfActiveAccount)
    }
    
    func matches<Action>(actionType: Action.Type) -> Bool where Action: UserAction {
        return _matchesType(actionType)
    }
    
    func matches(someActionType: UserAction.Type) -> Bool {
        return _matchesType(someActionType)
    }
    
    var actionType: UserAction.Type {
        return _actionType()
    }
}
