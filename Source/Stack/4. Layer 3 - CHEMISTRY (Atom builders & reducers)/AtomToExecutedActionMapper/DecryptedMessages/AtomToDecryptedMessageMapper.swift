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
import RxSwift

public protocol AtomToDecryptedMessageMapper: AtomToSpecificExecutedActionMapper, Throwing where
    SpecificExecutedAction == SentMessage,
    Error == DecryptMessageFromAtomMapperError {}

public final class DefaultAtomToDecryptedMessageMapper: AtomToDecryptedMessageMapper {
    private let jsonDecoder: JSONDecoder
    private let activeAccount: Observable<Account>
    public init(
        activeAccount: Observable<Account>,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.jsonDecoder = jsonDecoder
        self.activeAccount = activeAccount
    }
}

public extension DefaultAtomToDecryptedMessageMapper {
    func mapAtomToAction(_ atom: Atom) -> Observable<SentMessage?> {
        guard atom.spunParticles().contains(where: { $0.particle is MessageParticle }) else { return Observable.just(nil) }
        
        return activeAccount.flatMap {
            $0.privateKeyForSigning
        }.map {
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
    
    func decryptMessageIfNeeded(key: Signing) throws -> SentMessage {
        print("🔓 decrypting message")
        switch payload {
        case .wasNotEncrypted(let data):
            return SentMessage(context: self, data: data, encryptionState: .wasNotEncrypted)
        case .encrypted(let encryptedData, let encryptor):
            do {
                let decryptedData = try encryptor.decrypt(data: encryptedData, using: key)
                return SentMessage(context: self, data: decryptedData, encryptionState: .decrypted)
            } catch let decryptionError as ECIES.DecryptionError {
                return SentMessage(context: self, data: encryptedData, encryptionState: .cannotDecrypt(error: decryptionError))
            } catch let unhandledError {
                throw unhandledError
            }
        }
    }
}

// MARK: SentMessage from Context
private extension SentMessage {
    init(
        context: EncryptedMessageContext,
        data: Data,
        encryptionState: SentMessage.EncryptionState
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
