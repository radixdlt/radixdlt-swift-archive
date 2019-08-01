//
//  BurnTokensAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-30.
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
