//
//  TransferTokenActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public protocol TransferTokenActionToParticleGroupsMapper:
    StatefulActionToParticleGroupsMapper
where
    Action == TransferTokenAction,
    State == TokenBalanceState
{
    // swiftlint:enable colon opening_brace
}
