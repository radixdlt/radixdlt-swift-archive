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

// swiftlint:disable opening_brace

public protocol AtomToSendMessageActionMapper: AtomToSpecificExecutedActionMapper
    where
    SpecificExecutedAction == SendMessageAction,
    SpecificMappingError == DecryptMessageFromAtomMapperError
{}

// swiftlint:enable opening_brace

public final class DefaultAtomToSendMessageActionMapper: AtomToSendMessageActionMapper {
    private let activeAccount: AnyPublisher<Account, Never>
    public init(
        activeAccount: AnyPublisher<Account, Never>
    ) {
        self.activeAccount = activeAccount
    }
}

public extension DefaultAtomToSendMessageActionMapper {
    typealias SpecificMappingError = DecryptMessageFromAtomMapperError

    func mapError(_ error: SpecificMappingError) -> AtomToTransactionMapperError {
        AtomToTransactionMapperError.sendMessageActionMappingError(error)
    }
    
    func mapAtomToActions(_ atom: Atom) -> AnyPublisher<[SendMessageAction], SpecificMappingError> {
        guard atom.containsAnyMessageParticle() else {
            return Just([])
                .setFailureType(to: SpecificMappingError.self)
                .eraseToAnyPublisher()
        }
        
        let particleGroupsWithMessageParticles = atom.particleGroups.particleGroups
            .filter { $0.containsAnyMessageParticle() }
            
        let encryptedContexts: AnyPublisher<EncryptedMessageContext, DecryptMessageFromAtomMapperError> = Publishers.Sequence<[ParticleGroup], DecryptMessageFromAtomMapperError>(sequence: particleGroupsWithMessageParticles)
            .map { NonEmptyArray($0.messageParticles()) }
        .tryMap {
            try EncryptedMessageContext(messageParticles: $0)
        }
        .mapError { castOrKill(instance: $0, toType: DecryptMessageFromAtomMapperError.self) }
        .eraseToAnyPublisher()
            
        return encryptedContexts.combineLatest(
            activeAccount.flatMap { $0.privateKeyForSigning }.setFailureType(to: SpecificMappingError.self)
        )
        .tryMap { encryptedMessageContext, key in
            try encryptedMessageContext.decryptMessageIfNeeded(key: key)
        }
        .mapError { castOrKill(instance: $0, toType: DecryptMessageFromAtomMapperError.self) }
        .collect(particleGroupsWithMessageParticles.count)
        .eraseToAnyPublisher()
    }
}

public enum DecryptMessageFromAtomMapperError: Swift.Error, Equatable {
    case zeroMessageParticlesFound(in: Atom)
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
    
    // TODO Clean up and change fatalError to throwing error, also sync API layer design with other libraries
    init(messageParticles messageParticlesNonEmpty: NonEmptyArray<MessageParticle>) throws {
        
        func particleContainsMetaDataApplicationMessage(_ messageParticle: MessageParticle) -> Bool {
            messageParticle.metaData.contains(where: {
                $0.key == MetaDataKey.application &&
                    $0.value == MetaDataCommonValue.message.rawValue
            })
        }
        
        func printIfParticleLacksCorrectMetaData(_ messageParticle: MessageParticle) {
            guard particleContainsMetaDataApplicationMessage(messageParticle) == false else { return }
            
            print("⚠️ Application layer discrepancy, got message particle without any metadata with key-value: '\([MetaDataKey.application: MetaDataCommonValue.message]))', but proceeding anyway")
        }
    
        switch messageParticlesNonEmpty.countedElementsOneTwoAndMany {
        case .one(let singleMessageParticle):
            printIfParticleLacksCorrectMetaData(singleMessageParticle)
            try self.init(messageParticle: singleMessageParticle)
        case .two:
            let messageParticles = messageParticlesNonEmpty.elements
            
            let messageParticleWithApplicationMetaData = messageParticles.firstWhereMetaDataValueFor(key: .application, equals: .message)
            let messageParticleFallBack = messageParticles.firstWhereMetaDataValueFor(key: .application, notEquals: .encryptor)
            
            guard let messageParticle = (messageParticleWithApplicationMetaData ?? messageParticleFallBack) else {
                fatalError("Found no unencrypted message particle.")
            }
            
            guard let encryptorParticle = messageParticles
                .firstWhereMetaDataValueFor(key: .application, equals: .encryptor) else {
                    fatalError("Found no encryptor particle, does this ParticleGroup contain multiple unencrypted message particles?")
            }
            
            try self.init(messageParticle: messageParticle, encryptorParticle: encryptorParticle)
        case .many:
            fatalError("Unexpectedly got more than 2 message particles in same ParticleGroup, is this a bad state?")
        }
    }
    
    init(messageParticle: MessageParticle, encryptorParticle: MessageParticle? = nil) throws {
        
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
