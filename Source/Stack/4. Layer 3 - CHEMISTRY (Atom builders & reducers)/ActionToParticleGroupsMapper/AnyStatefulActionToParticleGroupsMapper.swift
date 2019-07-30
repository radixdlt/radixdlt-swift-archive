//
//  AnyStatefulActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AnyStatefulActionToParticleGroupsMapper: BaseStatefulActionToParticleGroupsMapper {
    
    private let _actionType: () -> UserAction.Type
    private let _matchesType: (UserAction.Type) -> Bool
    private let _requiredStateForAnAction: (UserAction) -> [AnyShardedParticleStateId]
    private let _particleGroupsForAnAction: (UserAction, [AnyUpParticle]) throws -> ParticleGroups
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: StatefulActionToParticleGroupsMapper {
        
        self._actionType = { Concrete.Action.self }
        self._matchesType = { return $0 == Concrete.Action.self }
        
        self._requiredStateForAnAction = { concrete.requiredStateForAnAction($0) }
        self._particleGroupsForAnAction = { try concrete.particleGroupsForAnAction($0, upParticles: $1) }
    }
}

public extension AnyStatefulActionToParticleGroupsMapper {
    
    func matches<Action>(actionType: Action.Type) -> Bool where Action: UserAction {
        return _matchesType(actionType)
    }
    
    private func matches(someActionType: UserAction.Type) -> Bool {
        return _matchesType(someActionType)
    }
    
    func matches(someAction: UserAction) -> Bool {
        return _matchesType(type(of: someAction))
    }
    
    var actionType: UserAction.Type {
        return _actionType()
    }
    
    func requiredStateForAnAction(_ userAction: UserAction) -> [AnyShardedParticleStateId] {
        return _requiredStateForAnAction(userAction)
    }
    
    func particleGroupsForAnAction(_ userAction: UserAction, upParticles: [AnyUpParticle]) throws -> ParticleGroups {
        return try _particleGroupsForAnAction(userAction, upParticles)
    }
    
}

// MARK: Stateless support
public extension AnyStatefulActionToParticleGroupsMapper {
    init<StatelessMapper>(statelessMapper: StatelessMapper) where StatelessMapper: StatelessActionToParticleGroupsMapper {
        
        self._actionType = { StatelessMapper.Action.self }
        self._matchesType = { return $0 == StatelessMapper.Action.self }
        
        self._requiredStateForAnAction = { _ in return [] }
        self._particleGroupsForAnAction = { action, _ in return statelessMapper.particleGroupsForAnAction(action) }
        
    }
    
    init(anyStatelessMapper: AnyStatelessActionToParticleGroupsMapper) {
        self._actionType = { anyStatelessMapper.actionType }
        self._matchesType = { return anyStatelessMapper.matches(someActionType: $0) }
        self._requiredStateForAnAction = { _ in return [] }
        self._particleGroupsForAnAction = { action, _ in return anyStatelessMapper.particleGroupsForAnAction(action) }
    }
}
