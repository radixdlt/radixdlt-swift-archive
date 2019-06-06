//
//  SendMessageAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SendMessageAction: UserAction {
    public let sender: Address
    public let recipient: Address
    public let payload: Data
    public let shouldBeEncrypted: Bool
    
    public init(
        from sender: Ownable,
        to recipient: Ownable,
        payload: Data,
        shouldBeEncrypted: Bool
    ) {
        self.sender = sender.address
        self.recipient = recipient.address
        self.payload = payload
        self.shouldBeEncrypted = shouldBeEncrypted
    }
}

public extension SendMessageAction {
    
    init(
        from sender: Ownable,
        to recipient: Ownable,
        message: String,
        encoding: String.Encoding = .default,
        shouldBeEncrypted: Bool = true
    ) {
        let payload = message.toData(encodingForced: encoding)
        
        self.init(
            from: sender,
            to: recipient,
            payload: payload,
            shouldBeEncrypted: shouldBeEncrypted
        )
    }
}
