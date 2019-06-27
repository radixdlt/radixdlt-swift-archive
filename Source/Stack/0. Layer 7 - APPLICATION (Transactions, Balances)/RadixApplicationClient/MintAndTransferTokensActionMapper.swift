//
//  MintAndTransferTokensActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct MintAndTransferAction: UserAction {
    public let tokenDefinitionReferece: ResourceIdentifier
    public let amount: PositiveAmount
    public let recipient: Address
}

public protocol MintAndTransferTokensActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper where Action == MintAndTransferAction {}

public extension MintAndTransferTokensActionToParticleGroupsMapper {
    func requiredState(for mintAndTransferAction: Action) -> [AnyShardedParticleStateId] {
        let tokenDefinitionAddress = mintAndTransferAction.tokenDefinitionReferece.address
        return [
            ShardedParticleStateId(typeOfParticle: UnallocatedTokensParticle.self, address: tokenDefinitionAddress)
        ].map {
            AnyShardedParticleStateId($0)
        }
    }
}

public final class DefaultMintAndTransferTokensActionToParticleGroupsMapper: MintAndTransferTokensActionToParticleGroupsMapper {
    public init() {}
}

public extension DefaultMintAndTransferTokensActionToParticleGroupsMapper {
    func particleGroups(for action: MintAndTransferAction, upParticles: [ParticleConvertible]) throws -> ParticleGroups {
        implementMe()
    }
}
