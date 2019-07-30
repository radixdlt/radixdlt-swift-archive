//
//  MintTokensActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol MintTokensActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper where Action == MintTokensAction {}

public extension MintTokensActionToParticleGroupsMapper {
    func requiredState(for mintTokensAction: Action) -> [AnyShardedParticleStateId] {
        let address = mintTokensAction.tokenDefinitionReferece.address
        return [
            AnyShardedParticleStateId(ShardedParticleStateId(typeOfParticle: UnallocatedTokensParticle.self, address: address)),
            AnyShardedParticleStateId(ShardedParticleStateId(typeOfParticle: TokenDefinitionParticle.self, address: address))
        ]
    }
}

public final class DefaultMintTokensActionToParticleGroupsMapper: MintTokensActionToParticleGroupsMapper {
    public init() {}
}

public extension DefaultMintTokensActionToParticleGroupsMapper {
    typealias Action = MintTokensAction
    func particleGroups(for action: Action, upParticles: [AnyUpParticle]) throws -> ParticleGroups {
        implementMe()
    }
}
