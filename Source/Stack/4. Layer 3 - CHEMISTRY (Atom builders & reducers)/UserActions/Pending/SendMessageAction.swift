//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public struct SendMessageAction: UserAction, ChatMessage {
    public let sender: Address
    public let recipient: Address
    public let payload: Data
    public let encryptionMode: MessageEncryptionMode
    
    internal init(
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

public extension SendMessageAction {
    var nameOfAction: UserActionName { return .sendMessage }
}

internal extension SendMessageAction {
    
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
    
    static func encrypted(
        from sender: Ownable,
        to recipient: Ownable,
        onlyDecryptableBy: [Ownable],
        text: String,
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
    
    static func encryptedDecryptableBySenderAndRecipient(
        and extraDecryptors: [Ownable]? = nil,
        from sender: Ownable,
        to recipient: Ownable,
        text: String,
        encoding: String.Encoding = .default
    ) -> SendMessageAction {
        
        // "or possibly more": https://www.youtube.com/watch?v=-9-cQTGdWHA&feature=youtu.be&t=68
        var senderAndRecipientOrPossibleMore: [Ownable] = [sender, recipient]
        if let extraDecryptors = extraDecryptors {
            senderAndRecipientOrPossibleMore.append(contentsOf: extraDecryptors)
        }
        
        return encrypted(from: sender, to: recipient, onlyDecryptableBy: senderAndRecipientOrPossibleMore, text: text, encoding: encoding)
    }
    
    static func encryptedDecryptableOnlyByRecipientAndSender(
        from sender: Ownable,
        to recipient: Ownable,
        text: String,
        encoding: String.Encoding = .default
    ) -> SendMessageAction {
        
        return encryptedDecryptableBySenderAndRecipient(and: nil, from: sender, to: recipient, text: text, encoding: encoding)
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
        case .plainText:
            return .plainText
        case .encryption(let onlyDecryptableBy):
            return .encrypt(onlyDecryptableBy: onlyDecryptableBy)
        case .encryptionSpecifyDecryptors(let encryptionSpecifyDecryptors):
            return encryptionSpecifyDecryptors([sender, recipient])
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
