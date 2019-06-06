//
//  DefaultSendMessageActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct DefaultSendMessageActionToParticleGroupsMapper: SendMessageActionToParticleGroupsMapper {
    public typealias KeysThatCanDecryptMessage = (SendMessageAction) -> [PublicKey]
    public typealias KeyGenerator = () -> KeyPair
    
    private let generateSharedKey: KeyGenerator
    
    /// PublicKey's that can decrypt the message
    private let readersOfMessage: KeysThatCanDecryptMessage
    
    private let encryptedPayloadJsonEncoder: JSONEncoder
    
    public init(
        sharedKeyGenerator: @escaping @autoclosure () -> KeyPair = KeyPair.init(),
        encryptedPayloadJsonEncoder: JSONEncoder = JSONEncoder(),
        // By default both sender and recipient of a message can decrypt it
        readers: @escaping KeysThatCanDecryptMessage = { return [$0.sender, $0.recipient].map { $0.publicKey } }
    ) {
        self.generateSharedKey = sharedKeyGenerator
        self.encryptedPayloadJsonEncoder = encryptedPayloadJsonEncoder
        self.readersOfMessage = readers
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
    
    func encryptDataIfNeeded(action: SendMessageAction) -> (data: Data, encryptorParticle: AnySpunParticle?) {
        var encryptorParticle: AnySpunParticle?
        let payload: Data = !action.shouldBeEncrypted ? action.payload : {
            do {
                let sharedKey = generateSharedKey()
                let readers = readersOfMessage(action)
                
                let encryptedPrivateKeys = try readers.map { try sharedKey.encryptPrivateKey(withPublicKey: $0) }
                let encryptor = Encryptor(protectors: encryptedPrivateKeys)
                
                let encryptorPayload = try encryptor.encodePayload(encoder: encryptedPayloadJsonEncoder)
                
                let messageEncryptorParticle = MessageParticle(
                    from: action.sender,
                    to: action.recipient,
                    payload: encryptorPayload,
                    metaData: [
                        MetaDataKey.application(.encryptor),
                        MetaDataKey.contentType(.applicationJson)
                    ]
                )
                    
                encryptorParticle = messageEncryptorParticle.withSpin(.up)
                
                let encryptedMessage = try sharedKey.publicKey.encrypt(action.payload)
                return encryptedMessage
            } catch { incorrectImplementation("Failed to encrypt message, error: \(error)") }
        }()
        
        return (data: payload, encryptorParticle: encryptorParticle)
    }
}
