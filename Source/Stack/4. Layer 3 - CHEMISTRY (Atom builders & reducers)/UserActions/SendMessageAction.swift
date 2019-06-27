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
    public let encryptionMode: MessageEncryptionMode
    
    private init(
        from sender: Ownable,
        to recipient: Ownable,
        payload: Data,
        encryption encryptionMode: EncryptionMode = .encryptedDecryptableOnlyByRecipientAndSender
    ) {
        self.sender = sender.address
        self.recipient = recipient.address
        self.payload = payload
        self.encryptionMode = encryptionMode.messageEncryptionMode(sender: sender, recipient: recipient)
    }
}

private extension SendMessageAction {
    
    init(
        text: String,
        encoding: String.Encoding = .default,
        from sender: Ownable,
        to recipient: Ownable,
        encryption encryptionMode: EncryptionMode = .encryptedDecryptableOnlyByRecipientAndSender
    ) {
        let payload = text.toData(encodingForced: encoding)
        self.init(from: sender, to: recipient, payload: payload, encryption: encryptionMode)
    }
}

public extension SendMessageAction {
    var shouldBeEncrypted: Bool {
        return encryptionMode.isEncryptionUsed
    }
}

// MARK: - Payload Data
public extension SendMessageAction {
    
    static func plainText(
        from sender: Ownable,
        to recipient: Ownable,
        payload: Data
    ) -> SendMessageAction {
        
        return SendMessageAction(
            from: sender,
            to: recipient,
            payload: payload,
            encryption: .plainText
        )
    }
    
    static func encryptedDecryptableOnlyByRecipientAndSender(
        from sender: Ownable,
        to recipient: Ownable,
        payload: Data
    ) -> SendMessageAction {
        
        return SendMessageAction(
            from: sender,
            to: recipient,
            payload: payload,
            encryption: .encryptedDecryptableOnlyByRecipientAndSender
        )
    }
    
    static func encrypted(
        from sender: Ownable,
        to recipient: Ownable,
        payload: Data,
        onlyDecryptableBy: [Ownable]
    ) -> SendMessageAction {
        
        return SendMessageAction(
            from: sender,
            to: recipient,
            payload: payload,
            encryption: .encryption(onlyDecryptableBy: onlyDecryptableBy)
        )
    }
}

// MARK: - Text Message
public extension SendMessageAction {
    
    static func plainText(
        from sender: Ownable,
        to recipient: Ownable,
        text: String,
        encoding: String.Encoding = .default
    ) -> SendMessageAction {
        let payload = text.toData(encodingForced: encoding)
        return SendMessageAction(
            from: sender,
            to: recipient,
            payload: payload,
            encryption: .plainText
        )
    }
    
    static func encryptedDecryptableOnlyByRecipientAndSender(
        from sender: Ownable,
        to recipient: Ownable,
        text: String,
        encoding: String.Encoding = .default
    ) -> SendMessageAction {
        
        let payload = text.toData(encodingForced: encoding)
        return SendMessageAction(
            from: sender,
            to: recipient,
            payload: payload,
            encryption: .encryptedDecryptableOnlyByRecipientAndSender
        )
    }
    
    static func encrypted(
        from sender: Ownable,
        to recipient: Ownable,
        text: String,
        onlyDecryptableBy: [Ownable],
        encoding: String.Encoding = .default
        ) -> SendMessageAction {
        
        let payload = text.toData(encodingForced: encoding)
        return SendMessageAction(
            from: sender,
            to: recipient,
            payload: payload,
            encryption: .encryption(onlyDecryptableBy: onlyDecryptableBy)
        )
    }
}

// MARK: - Private
public extension SendMessageAction {
    enum EncryptionMode {
        case plainText

        public typealias EncryptionSpecifyDecryptors = ([Ownable]) -> MessageEncryptionMode
        case encryptionSpecifyDecryptors(EncryptionSpecifyDecryptors)
        case encryption(onlyDecryptableBy: [Ownable])
    }
}

public extension SendMessageAction.EncryptionMode {
    
    func messageEncryptionMode(sender: Ownable, recipient: Ownable) -> MessageEncryptionMode {
        switch self {
        case .plainText: return .plainText
        case .encryption(let onlyDecryptableBy): return .encrypt(onlyDecryptableBy: onlyDecryptableBy)
        case .encryptionSpecifyDecryptors(let encryptionSpecifyDecryptors): return encryptionSpecifyDecryptors([sender, recipient])
        }
    }
    
    static func encrypted(decryptableOnlyBy decryptors: [Ownable]) -> SendMessageAction.EncryptionMode {
        return .encryption(onlyDecryptableBy: decryptors)
    }
    
    static var encryptedDecryptableOnlyByRecipientAndSender: SendMessageAction.EncryptionMode {
        let encryptionSpecifyDecryptors: EncryptionSpecifyDecryptors = {
            return MessageEncryptionMode.encrypt(onlyDecryptableBy: $0)
        }
        return .encryptionSpecifyDecryptors(encryptionSpecifyDecryptors)
    }
}
