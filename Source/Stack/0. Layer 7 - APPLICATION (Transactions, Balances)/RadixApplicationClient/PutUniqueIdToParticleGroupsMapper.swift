//
//  PutUniqueActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct PutUniqueIdAction: UserAction {}
public extension PutUniqueIdAction {
    var nameOfAction: UserActionName { return .putUnique }
}

public protocol PutUniqueActionToParticleGroupsMapper: StatelessActionToParticleGroupsMapper where Action == PutUniqueIdAction {}

public final class DefaultPutUniqueActionToParticleGroupsMapper: PutUniqueActionToParticleGroupsMapper { }

public extension DefaultPutUniqueActionToParticleGroupsMapper {
    typealias Action = PutUniqueIdAction
    func particleGroups(for action: Action) -> ParticleGroups {
        implementMe()
    }
}
