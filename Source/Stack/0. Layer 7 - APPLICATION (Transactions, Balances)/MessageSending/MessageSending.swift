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
import Combine

/// Important that `MessageSending` conforms to `ActiveAccountOwner` so that we can verify that the address
/// of a message `sender` is the same as the `addressOfActiveAccount` that signs the message. In order
/// to prevent incorrect input (which would fail at a later stage anyway) where Alice claims to be
/// Carol, when sending a message to Bob.
public protocol MessageSending: ActiveAccountOwner {
    
    /// Sends a message
    func send(message: SendMessageAction) -> PendingTransaction
    func observeMessages(toOrFrom address: Address) -> AnyPublisher<SendMessageAction, AtomToTransactionMapperError>
}

public extension MessageSending {
    func sendPlainTextMessage(
        _ plainText: String,
        encoding: String.Encoding = .default,
        to recipient: AddressConvertible
    ) -> PendingTransaction {
        
        let sendMessageAction = SendMessageAction.plainText(from: addressOfActiveAccount, to: recipient, text: plainText, encoding: encoding)
        
        return send(message: sendMessageAction)
    }
    
    func sendEncryptedMessage(
        _ textToEncrypt: String,
        encoding: String.Encoding = .default,
        to recipient: AddressConvertible,
        canAlsoBeDecryptedBy extraDecryptors: [AddressConvertible]? = nil
    ) -> PendingTransaction {
        
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
    func observeMyMessages() -> AnyPublisher<SendMessageAction, AtomToTransactionMapperError> {
        return observeMessages(toOrFrom: addressOfActiveAccount)
    }
}
