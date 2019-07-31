//
//  Transacting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

/// Type that is can make transactions of different types between Radix accounts
public protocol TokenTransferring {
    var addressOfActiveAccount: Address { get }
    func transfer(tokens: TransferTokenAction) -> ResultOfUserAction
    
    func observeTokenTransfers(toOrFrom address: Address) -> Observable<TransferredTokens>
}

public extension TokenTransferring {
    func transferTokens(
        identifier tokenIdentifier: ResourceIdentifier,
        to recipient: Ownable,
        amount: PositiveAmount,
        message: String,
        messageEncoding: String.Encoding = .default,
        from specifiedSender: Ownable? = nil
        ) -> ResultOfUserAction {
        
        let attachment = message.toData(encodingForced: messageEncoding)
        
        return transferTokens(
            identifier: tokenIdentifier,
            to: recipient,
            amount: amount,
            attachment: attachment,
            from: specifiedSender
        )
    }
    
    func transferTokens(
        identifier tokenIdentifier: ResourceIdentifier,
        to recipient: Ownable,
        amount: PositiveAmount,
        attachment: Data? = nil,
        from specifiedSender: Ownable? = nil
        ) -> ResultOfUserAction {
        
        let sender = specifiedSender ?? addressOfActiveAccount
        
        let transferAction = TransferTokenAction(
            from: sender,
            to: recipient,
            amount: amount,
            tokenResourceIdentifier: tokenIdentifier,
            attachment: attachment
        )
        
        return transfer(tokens: transferAction)
    }
}

public extension TokenTransferring {
    func observeMyTokenTransfers() -> Observable<TransferredTokens> {
        return observeTokenTransfers(toOrFrom: addressOfActiveAccount)
    }
}
