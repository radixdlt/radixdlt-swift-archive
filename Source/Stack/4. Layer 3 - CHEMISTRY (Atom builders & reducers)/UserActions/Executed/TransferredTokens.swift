//
//  TransferredTokens.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol TokenTransfer {
    var sender: Address { get }
    var recipient: Address { get }
    var amount: PositiveAmount { get }
    var tokenResourceIdentifier: ResourceIdentifier { get }
    var attachment: Data? { get }
}

/// A transfer of a non-zero amount of a certain token between two Radix accounts
public struct TransferredTokens: ExecutedAction, TokenTransfer {
    
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
        date: Date,
        attachment: Data?
    ) {
        self.sender = sender.address
        self.recipient = recipient.address
        self.amount = amount
        self.tokenResourceIdentifier = tokenResourceIdentifier
        self.date = date
        self.attachment = attachment
    }
}

// MARK: UserAction
public extension TransferredTokens {
    var nameOfAction: UserActionName { return .transferredTokens }
}

// MARK: Attachment as Message
public extension TransferredTokens {
    func attachedMessage(decodeAs encoding: String.Encoding = .default) -> String? {
        guard let attachmentData = attachment else { return nil }
        return String(data: attachmentData, encoding: encoding)
    }
}
