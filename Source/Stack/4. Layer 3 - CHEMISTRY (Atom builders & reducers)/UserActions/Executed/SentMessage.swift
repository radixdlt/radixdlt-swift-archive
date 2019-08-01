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

public protocol ChatMessage {
    var sender: Address { get }
    var recipient: Address { get }
    var payload: Data { get }
}

public struct SentMessage: ExecutedAction, ChatMessage {
    public let sender: Address
    public let recipient: Address
    public let payload: Data
    public let encryptionState: EncryptionState
    public let timestamp: Date
}

public extension SentMessage {
    enum EncryptionState: Equatable {
        
        /// Specifies that the payload in the SentMessage object WAS originally
        /// encrypted and has been successfully decrypted to it's present byte array.
        case decrypted
        
        /// Specifies that the payload in the SentMessage object was NOT
        /// encrypted and the present data byte array just represents the original data.
        case wasNotEncrypted
        
        /// Specifies that the data in the SentMessage object WAS encrypted
        /// but could not be decrypted. The present data byte array represents the still
        /// encrypted data.
        case cannotDecrypt(error: ECIES.DecryptionError)
    }
}

public extension SentMessage.EncryptionState {
    
    var isEncryptedButCannotDecrypt: Bool {
        switch self {
        case .cannotDecrypt(let reason):
            log.info(reason)
            return true
        case .decrypted, .wasNotEncrypted: return false
        }
    }
}

// MARK: UserAction
public extension SentMessage {
    var nameOfAction: UserActionName { return .sentMessage }
}
