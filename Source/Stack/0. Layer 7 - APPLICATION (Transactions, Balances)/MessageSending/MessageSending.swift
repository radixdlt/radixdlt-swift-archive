//
//  MessageSending.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol MessageSending {
    var addressOfActiveAccount: Address { get }
    
    /// Sends a message
    func send(message: SendMessageAction) -> ResultOfUserAction
    func observeMessages(toOrFrom address: Address) -> Observable<SentMessage>
}

public extension MessageSending {
    func sendPlainTextMessage(
        _ plainText: String,
        encoding: String.Encoding = .default,
        to recipient: Ownable
        ) -> ResultOfUserAction {
        
        let sendMessageAction = SendMessageAction.plainText(from: addressOfActiveAccount, to: recipient, text: plainText, encoding: encoding)
        
        return send(message: sendMessageAction)
    }
    
    func sendEncryptedMessage(
        _ textToEncrypt: String,
        encoding: String.Encoding = .default,
        to recipient: Ownable,
        canAlsoBeDecryptedBy extraDecryptors: [Ownable]? = nil
        ) -> ResultOfUserAction {
        
        let sendMessageAction = SendMessageAction.encryptedDecryptableBySenderAndRecipient(
            and: extraDecryptors,
            from: addressOfActiveAccount,
            to: recipient,
            text: textToEncrypt,
            encoding: encoding
        )
        
        return send(message: sendMessageAction)
    }
}

// MARK: Sent
public extension MessageSending {
    func observeMyMessages() -> Observable<SentMessage> {
        return observeMessages(toOrFrom: addressOfActiveAccount)
    }
}
