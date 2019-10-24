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

public protocol AtomToSendMessageActionMapper: AtomToSpecificExecutedActionMapper, Throwing where
    SpecificExecutedAction == SendMessageAction,
    Error == DecryptMessageFromAtomMapperError {}

public final class DefaultAtomToSendMessageActionMapper: AtomToSendMessageActionMapper {
    private let activeAccount: CombineObservable<Account>
    public init(
        activeAccount: CombineObservable<Account>
    ) {
        self.activeAccount = activeAccount
    }
}

public extension DefaultAtomToSendMessageActionMapper {
    func mapAtomToActions(_ atom: Atom) -> CombineObservable<[SendMessageAction]> {
        guard atom.containsAnyMessageParticle() else {
            return Just([]).eraseToAnyPublisher()
        }
        
//        return activeAccount.flatMap {
//            $0.privateKeyForSigning
//        }.map {
//            try EncryptedMessageContext(atom: atom).decryptMessageIfNeeded(key: $0)
//        }.map {
//            [$0]
//        }
        incorrectImplementation()
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
    
    fileprivate let sender: Address
    fileprivate let recipient: Address
    fileprivate let payload: Payload
    
    init(
        sender: Address,
        recipient: Address,
        payload: Payload
    ) {
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
        
        try self.init(messageParticles: messageParticles)
    }
    
    init(messageParticles: [MessageParticle]) throws {
        guard let messageParticle = messageParticles.firstWhereMetaDataValueFor(key: .application, equals: .message) else {
            throw DecryptMessageFromAtomMapperError.zeroMessageParticlesWithoutEncryptorMetaDataFound
        }
        
        let encryptorParticle = messageParticles.firstWhereMetaDataValueFor(key: .application, equals: .encryptor)
        
        try self.init(messageParticle: messageParticle, encryptorParticle: encryptorParticle)
    }
    
    init(messageParticle: MessageParticle, encryptorParticle: MessageParticle?) throws {

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
    
    func decryptMessageIfNeeded(key: Signing) throws -> SendMessageAction {
        switch payload {
        case .wasNotEncrypted(let data):
            return SendMessageAction(context: self, data: data, decryptContext: .wasNotEncrypted)
        case .encrypted(let encryptedData, let encryptor):
            do {
                let decryptedData = try encryptor.decrypt(data: encryptedData, using: key)
                return SendMessageAction(context: self, data: decryptedData, decryptContext: .decrypted)
            } catch let decryptionError as ECIES.DecryptionError {
                return SendMessageAction(context: self, data: encryptedData, decryptContext: .cannotDecrypt(error: decryptionError))
            } catch let unhandledError {
                throw unhandledError
            }
        }
    }
}

// MARK: SentMessage from Context
private extension SendMessageAction {
    init(
        context: EncryptedMessageContext,
        data: Data,
        decryptContext: EncryptionMode.DecryptedContext
        ) {
        
        self.init(
            from: context.sender,
            to: context.recipient,
            payload: data,
            decryption: decryptContext
        )
    }
}
