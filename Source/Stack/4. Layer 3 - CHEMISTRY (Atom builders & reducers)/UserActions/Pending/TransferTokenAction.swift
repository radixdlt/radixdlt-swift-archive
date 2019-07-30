//
//  TransferTokenAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A transfer of a non-zero amount of a certain token between two Radix accounts
public struct TransferTokenAction: UserAction, TokenTransfer {
    
    public let sender: Address
    public let recipient: Address
    public let amount: PositiveAmount
    public let tokenResourceIdentifier: ResourceIdentifier
    public let date: Date
    public let attachment: Data?
    
    public init(
        from sender: Ownable,
        to recipient: Ownable,
        amount: PositiveAmount,
        tokenResourceIdentifier: ResourceIdentifier,
        attachment: Data? = nil,
        date: Date = .init()
    ) {
        self.sender = sender.address
        self.recipient = recipient.address
        self.amount = amount
        self.tokenResourceIdentifier = tokenResourceIdentifier
        self.date = date
        self.attachment = attachment
    }
}

public extension TransferTokenAction {
    var nameOfAction: UserActionName { return .transferTokens }
}

