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

public struct SendMessageAction: UserAction {
    public let sender: Address
    public let recipient: Address
    public let payload: Data
    public let encryptionMode: EncryptionMode
    
    private init(
        from sender: AddressConvertible,
        to recipient: AddressConvertible,
        payload: Data,
        encryptionMode: EncryptionMode
    ) {
        self.sender = sender.address
        self.recipient = recipient.address
        self.payload = payload
        self.encryptionMode = encryptionMode
    }
}

// MARK: UserAction
public extension SendMessageAction {
    var user: Address { return sender }
    var nameOfAction: UserActionName { return .sendMessage }
}

// MARK: `Designated` Initializers
// (cannot be moved to another file since main initializer is `private` (and ought to be))

// Public `designated` initializer, only exposing messages to be encryped (`.plaintext` is an available encryption mode).
public extension SendMessageAction {
    init(
        from sender: AddressConvertible,
        to recipient: AddressConvertible,
        payload: Data,
        encryption encryptionContextBuilder: EncryptionMode.EncryptContext.Builder = .encryptedDecryptableOnlyByRecipientAndSender
    ) {
        
        let encryptionContext = encryptionContextBuilder.messageEncryptionContext(sender: sender, recipient: recipient)
        
        self.init(
            from: sender,
            to: recipient,
            payload: payload,
            encryptionMode: .encryptContext(encryptionContext)
        )
    }
}

// Internal (instead of `private`) since used by `AtomToSendMessageActionMapper`
internal extension SendMessageAction {
    init(
        from sender: AddressConvertible,
        to recipient: AddressConvertible,
        payload: Data,
        decryption decryptedContext: EncryptionMode.DecryptedContext
    ) {
        let encryptionMode = EncryptionMode.decryptContext(decryptedContext)
        self.init(from: sender, to: recipient, payload: payload, encryptionMode: encryptionMode)
    }
}

// MARK: Payload as Message
public extension SendMessageAction {
    func textMessage(decodeAs encoding: String.Encoding = .default) -> String? {
        switch encryptionMode {
        case .decryptContext(.cannotDecrypt): return nil
        default: return String(data: payload, encoding: encoding)
        }
    }
}
