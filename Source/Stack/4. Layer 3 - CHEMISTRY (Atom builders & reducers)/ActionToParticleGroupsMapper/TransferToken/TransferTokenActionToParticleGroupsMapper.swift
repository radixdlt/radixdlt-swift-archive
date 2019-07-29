//
//  TransferTokensActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol TransferTokensActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper where Action == TransferTokenAction {}

public extension TransferTokensActionToParticleGroupsMapper {
    
    func requiredState(for transferAction: Action) -> [AnyShardedParticleStateId] {
        return [
            ShardedParticleStateId(typeOfParticle: TransferrableTokensParticle.self, address: transferAction.sender)
        ].map {
            AnyShardedParticleStateId($0)
        }
    }
}
