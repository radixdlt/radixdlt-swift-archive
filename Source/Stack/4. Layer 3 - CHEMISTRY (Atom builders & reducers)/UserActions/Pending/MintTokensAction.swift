//
//  MintTokensAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct MintTokensAction: UserAction {
    public let tokenDefinitionReferece: ResourceIdentifier
    public let amount: PositiveAmount
}

public extension MintTokensAction {
    var nameOfAction: UserActionName { return .mintTokens }
}
