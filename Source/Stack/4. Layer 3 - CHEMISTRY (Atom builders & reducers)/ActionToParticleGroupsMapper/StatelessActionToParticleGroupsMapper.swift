//
//  StatelessActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol BaseStatelessActionToParticleGroupsMapper {
     func particleGroupsForAnAction(_ userAction: UserAction) -> ParticleGroups
}

public protocol StatelessActionToParticleGroupsMapper: BaseStatelessActionToParticleGroupsMapper {
    associatedtype Action: UserAction
    func particleGroups(for action: Action) -> ParticleGroups
}

public extension StatelessActionToParticleGroupsMapper {
    
    func particleGroupsForAnAction(_ userAction: UserAction) -> ParticleGroups {
        let action = castOrKill(instance: userAction, toType: Action.self)
        return particleGroups(for: action)
    }
}
