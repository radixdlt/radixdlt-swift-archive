//
//  DecryptMessageReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomToDecryptedMessageMapper: AtomToSpecificExecutedActionMapper, Throwing where
    ExecutedAction == DecryptedMessage,
    Error == DecryptMessageFromAtomMapperError {}

public final class DefaultAtomToDecryptedMessageMapper: AtomToDecryptedMessageMapper {
    private let jsonDecoder: JSONDecoder
    
    public init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }
}

public extension DefaultAtomToDecryptedMessageMapper {
    typealias ExecutedAction = DecryptedMessage
    func map(atom: Atom, account: Account) -> Observable<ExecutedAction> {
        return account.privateKeyForSigning.map {
            try EncryptedMessageContext(atom: atom).decryptMessageIfNeeded(key: $0)
        }
    }
}

public enum DecryptMessageFromAtomMapperError: Swift.Error {
    case zeroMessageParticlesFound(in: Atom)
    case zeroMessageParticlesWithoutEncryptorMetaDataFound
    case incorrectMetaDataValueForApplication(expected: String, butGot: String?)
}

private struct EncryptedMessageContext {
    enum Payload {
        case encrypted(data: Data, encryptedBy: Encryptor)
        case wasNotEncrypted(Data)
    }
    
    fileprivate let timestamp: Date
    fileprivate let sender: Address
    fileprivate let recipient: Address
    fileprivate let payload: Payload
    
    init(
        timestamp: Date,
        sender: Address,
        recipient: Address,
        payload: Payload
        ) {
        self.timestamp = timestamp
        self.sender = sender
        self.recipient = recipient
        self.payload = payload
    }
}

// MARK: - From Atom
private extension EncryptedMessageContext {
    
    init(atom: Atom) throws {
        
        guard case let messageParticles = atom.messageParticles(), !messageParticles.isEmpty else {
            throw DecryptMessageFromAtomMapperError.zeroMessageParticlesFound(in: atom)
        }
        
        try self.init(messageParticles: messageParticles, timestamp: atom.metaData.timestamp)
    }
    
    init(messageParticles: [MessageParticle], timestamp: Date) throws {
        guard let messageParticle = messageParticles.firstWhereMetaDataValueFor(key: .application, equals: .message) else {
            throw DecryptMessageFromAtomMapperError.zeroMessageParticlesWithoutEncryptorMetaDataFound
        }
        
        let encryptorParticle = messageParticles.firstWhereMetaDataValueFor(key: .application, equals: .encryptor)
        
        try self.init(messageParticle: messageParticle, encryptorParticle: encryptorParticle, timestamp: timestamp)
    }
    
    init(messageParticle: MessageParticle, encryptorParticle: MessageParticle?, timestamp: Date) throws {

        try EncryptedMessageContext.ensureMetaDataApplication(value: .message, in: messageParticle)
        
        let encryptor: Encryptor? = try {
            guard let encryptorParticle = encryptorParticle else {
                return nil
            }
    
            try EncryptedMessageContext.ensureMetaDataApplication(value: .encryptor, in: encryptorParticle)
            
            return try Encryptor.fromData(encryptorParticle.payload)
        }()
        
        let payload: Payload = {
            if let encryptor = encryptor {
                return .encrypted(data: messageParticle.payload, encryptedBy: encryptor)
            } else {
                return .wasNotEncrypted(messageParticle.payload)
            }
        }()
        
        self.init(
            timestamp: timestamp,
            sender: messageParticle.from,
            recipient: messageParticle.to,
            payload: payload
        )
    }
    
    static func ensureMetaDataApplication(value expected: MetaDataCommonValue, in particle: MessageParticle) throws {
        guard particle.valueFor(key: .application, equals: expected) else {
            throw DecryptMessageFromAtomMapperError.incorrectMetaDataValueForApplication(
                expected: expected.rawValue,
                butGot: particle.metaData.valueFor(key: MetaDataKey.application)
            )
        }
        // Everything is fine!
    }
    
}

// MARK: - Decrypt Message
private extension EncryptedMessageContext {
    
    func decryptMessageIfNeeded(key: Signing) throws -> DecryptedMessage {
        switch payload {
        case .wasNotEncrypted(let data):
            return DecryptedMessage(context: self, data: data, encryptionState: .wasNotEncrypted)
        case .encrypted(let encryptedData, let encryptor):
            do {
                let decryptedData = try encryptor.decrypt(data: encryptedData, using: key)
                return DecryptedMessage(context: self, data: decryptedData, encryptionState: .decrypted)
            } catch let decryptionError as ECIES.DecryptionError {
                return DecryptedMessage(context: self, data: encryptedData, encryptionState: .cannotDecrypt(error: decryptionError))
            } catch let unhandledError {
                throw unhandledError
            }
        }
    }
}

// MARK: DecryptedMessage from Context
private extension DecryptedMessage {
    init(
        context: EncryptedMessageContext,
        data: Data,
        encryptionState: DecryptedMessage.EncryptionState
    ) {
        self.init(
            sender: context.sender,
            recipient: context.recipient,
            payload: data,
            encryptionState: encryptionState,
            timestamp: context.timestamp
        )
    }
}
