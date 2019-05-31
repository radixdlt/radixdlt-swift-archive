//
//  DecryptMessageReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DecryptMessageReducer: Throwing where Error == DecryptMessageReducerError {
    func decryptMessage(in atom: Atom, using key: Signing) throws -> DecryptedMessage
}

public struct DefaultDecryptMessageReducer: DecryptMessageReducer {
    
    private let jsonDecoder: JSONDecoder
    
    public init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }
    
}

public extension DefaultDecryptMessageReducer {
    
    // swiftlint:disable:next function_body_length
    func decryptMessage(in atom: Atom, using key: Signing) throws -> DecryptedMessage {
        guard
            case let messageParticles = atom.messageParticles(),
            !messageParticles.isEmpty else {
                throw Error.zeroMessageParticlesFound(in: atom)
        }
    
        guard
            let bytesParticle = messageParticles.firstWhereMetaDataValueFor(key: .application, notEquals: .encryptor)
            else {
                throw Error.zeroEncryptedMessageParticlesFound(in: atom)
        }
        
        let mode: Payload.Mode = try {
            guard let encryptorParticle = messageParticles.firstWhereMetaDataValueFor(key: .application, equals: .encryptor) else {
                return .noEncryption
            }
  
            let encryptor = try Encryptor.fromData(encryptorParticle.payload)
            return .encryption(encryptor: encryptor)
        }()
        
        let timestamp = atom.metaData.timestamp
        
        let metaData: [MetaDataKey: Any] = [
            MetaDataKey.encrypted: mode.isEncrypted,
            .timestamp: timestamp,
            "signatures": atom.signatures
        ]
        
        let encryptedPayload = bytesParticle.payload
        
        let payload = Payload(
            payload: encryptedPayload,
            metaData: metaData,
            mode: mode
        )
        
        let sender = bytesParticle.from
        let recipient = bytesParticle.to
        
        do {
            let unencryptedData = try key.decrypt(payload: payload)

            return DecryptedMessage(
                sender: sender,
                recipient: recipient,
                payload: unencryptedData.payload,
                encryptionState: unencryptedData.encryptionState,
                timestamp: timestamp
            )
        } catch let decryptionError as ECIES.DecryptionError {
            return DecryptedMessage(
                sender: sender,
                recipient: recipient,
                payload: encryptedPayload,
                encryptionState: .cannotDecrypt(error: decryptionError),
                timestamp: timestamp
            )
        } catch { incorrectImplementation("Unhandled error: \(error)") }
    }
}

public enum DecryptMessageReducerError: Swift.Error {
    case zeroMessageParticlesFound(in: Atom)
    case zeroEncryptedMessageParticlesFound(in: Atom)
}
