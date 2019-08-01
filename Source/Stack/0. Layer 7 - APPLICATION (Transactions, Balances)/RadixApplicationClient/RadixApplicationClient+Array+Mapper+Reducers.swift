//
//  Array+MApperAndReducers.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Presets
public extension Array where Element == AnyAtomToExecutedActionMapper {
    static var `default`: [AnyAtomToExecutedActionMapper] {
        return [
            AnyAtomToExecutedActionMapper(DefaultAtomToTokenTransferMapper()),
            AnyAtomToExecutedActionMapper(DefaultAtomToDecryptedMessageMapper())
        ]
    }
}

public extension Array where Element == AnyParticleReducer {
    static var `default`: [AnyParticleReducer] {
        return [
            AnyParticleReducer(TokenBalanceReferencesReducer()),
            AnyParticleReducer(TokenDefinitionsReducer())
        ]
    }
}

public extension Array where Element == AnyStatefulActionToParticleGroupsMapper {
    static var `default`: [AnyStatefulActionToParticleGroupsMapper] {
        return [
            AnyStatefulActionToParticleGroupsMapper(DefaultMintTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultBurnTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultTransferTokensActionToParticleGroupsMapper())
        ]
    }
}

public extension Array where Element == AnyStatelessActionToParticleGroupsMapper {
    static var `default`: [AnyStatelessActionToParticleGroupsMapper] {
        return [
            AnyStatelessActionToParticleGroupsMapper(DefaultSendMessageActionToParticleGroupsMapper()),
            AnyStatelessActionToParticleGroupsMapper(DefaultCreateTokenActionToParticleGroupsMapper()),
            AnyStatelessActionToParticleGroupsMapper(DefaultPutUniqueActionToParticleGroupsMapper())
        ]
    }
}
