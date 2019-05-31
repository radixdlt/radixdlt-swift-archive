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
    private let readers: KeysThatCanDecryptMessage
    private let encryptedPayloadJsonEncoder: JSONEncoder
    
    public init(
        sharedKeyGenerator: @escaping @autoclosure () -> KeyPair = KeyPair.init(),
        encryptedPayloadJsonEncoder: JSONEncoder = JSONEncoder(),
        // By default both sender and recipient of a message can decrypt it
        readers: @escaping KeysThatCanDecryptMessage = { return [$0.sender, $0.recipient].map { $0.publicKey } }
    ) {
        self.generateSharedKey = sharedKeyGenerator
        self.encryptedPayloadJsonEncoder = encryptedPayloadJsonEncoder
        self.readers = readers
    }
}
public extension DefaultSendMessageActionToParticleGroupsMapper {
    // swiftlint:disable:next function_body_length
    func particleGroups(for action: SendMessageAction) -> ParticleGroups {
        var particles = [AnySpunParticle]()
        let payload: Data = !action.shouldBeEncrypted ? action.payload : {
            do {
                let sharedKey = generateSharedKey()
                let encryptor = try Encryptor(sharedKey: sharedKey, readers: readers(action))
                let encryptorPayload = try encryptor.encodePayload(encoder: encryptedPayloadJsonEncoder)
               
                let encryptorParticle = MessageParticle(
                    from: action.sender,
                    to: action.recipient,
                    payload: encryptorPayload,
                    metaData: [
                        MetaDataKey.application(.encryptor),
                        MetaDataKey.contentType(.applicationJson)
                    ]
                )
                
                particles += encryptorParticle.withSpin(.up)
                
                let encryptedMessage = try sharedKey.publicKey.encrypt(action.payload)
                return encryptedMessage
            } catch { incorrectImplementation("Failed to encrypt message, error: \(error)") }
        }()
        
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
