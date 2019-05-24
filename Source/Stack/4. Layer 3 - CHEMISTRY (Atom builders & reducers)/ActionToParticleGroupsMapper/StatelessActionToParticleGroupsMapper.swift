//
//  StatelessActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol StatelessActionToParticleGroupsMapper {
    associatedtype Action: UserAction
    func particleGroups(for action: Action) -> ParticleGroups
}

public protocol StatefulActionToParticleGroupsMapper {
    associatedtype Action: UserAction
    associatedtype State: ApplicationState
    func particleGroups(for action: Action, state: State) throws -> ParticleGroups
}
