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

public extension SendMessageAction.EncryptionMode.EncryptContext {
    enum Builder {
        public typealias EncryptionSpecifyDecryptors = ([AddressConvertible]) -> SendMessageAction.EncryptionMode.EncryptContext
        case encryptionSpecifyDecryptors(EncryptionSpecifyDecryptors)
        case encryption(onlyDecryptableBy: [AddressConvertible])
        case plainText
    }
}

public extension SendMessageAction.EncryptionMode.EncryptContext.Builder {
    
    static func encrypted(decryptableOnlyBy decryptors: [AddressConvertible]) -> SendMessageAction.EncryptionMode.EncryptContext.Builder {
        return .encryption(onlyDecryptableBy: decryptors)
    }
    
    static var encryptedDecryptableOnlyByRecipientAndSender: SendMessageAction.EncryptionMode.EncryptContext.Builder {
        let encryptionSpecifyDecryptors: EncryptionSpecifyDecryptors = {
            return SendMessageAction.EncryptionMode.EncryptContext.encrypt(onlyDecryptableBy: $0)
        }
        return .encryptionSpecifyDecryptors(encryptionSpecifyDecryptors)
    }
}

public extension SendMessageAction.EncryptionMode.EncryptContext.Builder {
    func messageEncryptionContext(sender: AddressConvertible, recipient: AddressConvertible) -> SendMessageAction.EncryptionMode.EncryptContext {
        switch self {
        case .plainText:
            return .plainText
        case .encryption(let onlyDecryptableBy):
            return .encrypt(onlyDecryptableBy: onlyDecryptableBy)
        case .encryptionSpecifyDecryptors(let encryptionSpecifyDecryptors):
            return encryptionSpecifyDecryptors([sender, recipient])
        }
    }
}
