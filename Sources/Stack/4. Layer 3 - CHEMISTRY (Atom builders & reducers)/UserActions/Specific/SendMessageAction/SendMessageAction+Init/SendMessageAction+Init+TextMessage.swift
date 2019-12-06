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

// MARK: - Text Message
public extension SendMessageAction {
    
    init(
        text: String,
        encoding: String.Encoding = .default,
        from sender: AddressConvertible,
        to recipient: AddressConvertible,
        encryption encryptionContextBuilder: SendMessageAction.EncryptionMode.EncryptContext.Builder = .encryptedDecryptableOnlyByRecipientAndSender
    ) {
        
        let payload = text.toData(encodingForced: encoding)
        
        self.init(from: sender, to: recipient, payload: payload, encryption: encryptionContextBuilder)
    }
    
    static func plainText(
        from sender: AddressConvertible,
        to recipient: AddressConvertible,
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
        from sender: AddressConvertible,
        to recipient: AddressConvertible,
        onlyDecryptableBy: [AddressConvertible],
        text: String,
        encoding: String.Encoding = .default
    ) -> SendMessageAction {
        
        let payload = text.toData(encodingForced: encoding)
        return SendMessageAction(
            from: sender,
            to: recipient,
            payload: payload,
            encryption: .encryption(onlyDecryptableBy: onlyDecryptableBy.map { $0.address })
        )
    }
    
    static func encryptedDecryptableBySenderAndRecipient(
        and extraDecryptors: [AddressConvertible]? = nil,
        from sender: AddressConvertible,
        to recipient: AddressConvertible,
        text: String,
        encoding: String.Encoding = .default
    ) -> SendMessageAction {
        
        // "or possibly more": https://www.youtube.com/watch?v=-9-cQTGdWHA&feature=youtu.be&t=68
        var senderAndRecipientOrPossibleMore: [AddressConvertible] = [sender, recipient]
        if let extraDecryptors = extraDecryptors {
            senderAndRecipientOrPossibleMore.append(contentsOf: extraDecryptors)
        }
        
        return encrypted(from: sender, to: recipient, onlyDecryptableBy: senderAndRecipientOrPossibleMore, text: text, encoding: encoding)
    }
    
    static func encryptedDecryptableOnlyByRecipientAndSender(
        from sender: AddressConvertible,
        to recipient: AddressConvertible,
        text: String,
        encoding: String.Encoding = .default
    ) -> SendMessageAction {
        
        return encryptedDecryptableBySenderAndRecipient(and: nil, from: sender, to: recipient, text: text, encoding: encoding)
    }
}
