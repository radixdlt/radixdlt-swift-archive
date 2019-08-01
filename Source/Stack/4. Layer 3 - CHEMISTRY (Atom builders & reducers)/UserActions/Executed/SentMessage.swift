//
//  SentMessage.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
