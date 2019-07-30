//
//  AnyStatelessActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AnyStatelessActionToParticleGroupsMapper: BaseStatelessActionToParticleGroupsMapper {
    
    private let _actionType: () -> UserAction.Type
    private let _matchesType: (UserAction.Type) -> Bool
    private let _particleGroupsForAnAction: (UserAction) -> ParticleGroups
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: StatelessActionToParticleGroupsMapper {
        self._actionType = { Concrete.Action.self }
        self._matchesType = { return $0 == Concrete.Action.self }
        
        self._particleGroupsForAnAction = { concrete.particleGroupsForAnAction($0) }
    }
}

public extension AnyStatelessActionToParticleGroupsMapper {
    func particleGroupsForAnAction(_ userAction: UserAction) -> ParticleGroups {
        return self._particleGroupsForAnAction(userAction)
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
