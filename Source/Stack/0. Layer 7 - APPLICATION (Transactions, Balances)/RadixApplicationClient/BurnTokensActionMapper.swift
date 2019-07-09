//
//  BurnTokensActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct BurnTokensAction: UserAction {
    public let address: Address
    public let tokenDefinitionReference: ResourceIdentifier
    public let amount: PositiveAmount
}

public extension BurnTokensAction {
    var nameOfAction: UserActionName { return .burnTokens }
}

public protocol BurnTokensActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper where Action == BurnTokensAction {}

public extension BurnTokensActionToParticleGroupsMapper {
    func requiredState(for burnTokensAction: Action) -> [AnyShardedParticleStateId] {
        return [
            ShardedParticleStateId(typeOfParticle: TransferrableTokensParticle.self, address: burnTokensAction.address)
            ].map {
                AnyShardedParticleStateId($0)
        }
    }
}

public final class DefaultBurnTokensActionToParticleGroupsMapper: BurnTokensActionToParticleGroupsMapper {
    public init() {}
}

public extension DefaultBurnTokensActionToParticleGroupsMapper {
   
    func particleGroups(for action: BurnTokensAction, upParticles: [ParticleConvertible]) throws -> ParticleGroups {
        implementMe()
    }
}
