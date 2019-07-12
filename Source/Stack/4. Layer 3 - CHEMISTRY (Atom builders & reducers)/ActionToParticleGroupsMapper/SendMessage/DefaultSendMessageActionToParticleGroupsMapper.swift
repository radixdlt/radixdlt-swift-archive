//
//  DefaultSendMessageActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class DefaultSendMessageActionToParticleGroupsMapper: SendMessageActionToParticleGroupsMapper {
    public typealias KeyGenerator = () -> KeyPair
    
    private let generateSharedKey: KeyGenerator
    private let encryptedPayloadJsonEncoder: JSONEncoder
    
    public init(
        sharedKeyGenerator: @escaping @autoclosure () -> KeyPair = KeyPair.init(),
        encryptedPayloadJsonEncoder: JSONEncoder = JSONEncoder()    ) {
        self.generateSharedKey = sharedKeyGenerator
        self.encryptedPayloadJsonEncoder = encryptedPayloadJsonEncoder
    }
    deinit {
        log.warning("🧨")
    }
}
public extension DefaultSendMessageActionToParticleGroupsMapper {

    func particleGroups(for action: SendMessageAction) -> ParticleGroups {
        var particles = [AnySpunParticle]()

        let (payload, encryptorParticle) = encryptDataIfNeeded(action: action)
        
        if let encryptorParticle = encryptorParticle {
            particles += encryptorParticle
        }
        
        let messageParticle = MessageParticle(
            from: action.sender,
            to: action.recipient,
            payload: payload,
            metaData: [MetaDataKey.application(.message)]
        )
        
        particles += messageParticle.withSpin(.up)
        
        return [ParticleGroup(spunParticles: particles)]
    }
}

private extension DefaultSendMessageActionToParticleGroupsMapper {
    
    /// PublicKey's that can decrypt the message
    func readersOf(message sendMessageAction: SendMessageAction) -> [PublicKey] {
        switch sendMessageAction.encryptionMode {
        case .encrypt(let readers):
            return readers.map { $0.address.publicKey }
        case .plainText:
            incorrectImplementation("Dont call this function if you are not encrypting message")
        }
    }
    
    func encryptDataIfNeeded(action sendMessageAction: SendMessageAction) -> (data: Data, encryptorParticle: AnySpunParticle?) {
        var encryptorParticle: AnySpunParticle?
        let payload: Data = !sendMessageAction.shouldBeEncrypted ? sendMessageAction.payload : {
            do {
                let sharedKey = generateSharedKey()
                let readers = readersOf(message: sendMessageAction)
                
                let encryptedPrivateKeys = try readers.map { try sharedKey.encryptPrivateKey(withPublicKey: $0) }
                let encryptor = Encryptor(protectors: encryptedPrivateKeys)
                
                let encryptorPayload = try encryptor.encodePayload(encoder: encryptedPayloadJsonEncoder)
                
                let messageEncryptorParticle = MessageParticle(
                    from: sendMessageAction.sender,
                    to: sendMessageAction.recipient,
                    payload: encryptorPayload,
                    metaData: [
                        MetaDataKey.application(.encryptor),
                        MetaDataKey.contentType(.applicationJson)
                    ]
                )
                    
                encryptorParticle = messageEncryptorParticle.withSpin(.up)
                
                let encryptedMessage = try sharedKey.publicKey.encrypt(sendMessageAction.payload)
                return encryptedMessage
            } catch { incorrectImplementation("Failed to encrypt message, error: \(error)") }
        }()
        
        return (data: payload, encryptorParticle: encryptorParticle)
    }
}
