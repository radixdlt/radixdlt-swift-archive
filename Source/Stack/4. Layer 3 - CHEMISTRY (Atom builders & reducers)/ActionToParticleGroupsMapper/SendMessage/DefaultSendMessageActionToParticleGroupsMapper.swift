//
//  DefaultSendMessageActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol KeyGenerating {
    func generateKeyPair() -> KeyPair
}

public struct KeyGenerator: KeyGenerating {
    public init() {}
    
    public func generateKeyPair() -> KeyPair {
        return KeyPair()
    }
}

public struct DefaultSendMessageActionToParticleGroupsMapper: SendMessageActionToParticleGroupsMapper {
    
    private let keyGenerator: KeyGenerating
    public typealias KeysSelector = (SendMessageAction) -> [PublicKey]
    private let keysSelector: KeysSelector
    
    public init(
        keyGenerator: KeyGenerating = KeyGenerator(),
        keysSelector: @escaping KeysSelector = { return [$0.sender, $0.recipient].map { $0.publicKey } }
    ) {
        self.keyGenerator = keyGenerator
        self.keysSelector = keysSelector
    }
}

public extension DefaultSendMessageActionToParticleGroupsMapper {
    // swiftlint:disable:next function_body_length
    func particleGroups(for action: SendMessageAction) -> ParticleGroups {
        var particles = [AnySpunParticle]()
        let payload: Data = !action.shouldBeEncrypted ? action.payload : {
            do {
                let sharedKey = keyGenerator.generateKeyPair()
                let encryptor = try Encryptor(sharedKey: sharedKey, readers: keysSelector(action))
                
                let privateKeysStringArray = encryptor.protectors.map { $0.base64 }
                let encryptorPayload = try JSONEncoder().encode(privateKeysStringArray)
                
                let encryptorParticle = MessageParticle(
                    from: action.sender,
                    to: action.recipient,
                    payload: encryptorPayload,
                    metaData: [.application: "encryptor", .contentType: "application/json"]
                )
                
                particles += encryptorParticle.withSpin(.up)
                
                return try sharedKey.publicKey.encrypt(action.payload)
            } catch { incorrectImplementation("Failed to encrypt message, error: \(error)") }
        }()
        
        let messageParticle = MessageParticle(
            from: action.sender,
            to: action.recipient,
            payload: payload,
            metaData: [.application: "message"]
        )
        
        particles += messageParticle.withSpin(.up)
        
        return [ParticleGroup(spunParticles: particles)]
    }
}

public struct Encryptor {
    
    public let protectors: [EncryptedPrivateKey]
    
    public init(protectors: [EncryptedPrivateKey]) {
        self.protectors = protectors
    }
    
    public init(sharedKey: KeyPair, readers: [PublicKey]) throws {
        let protectors = try readers.map { try sharedKey.encryptPrivateKey(withPublicKey: $0) }
        self.init(protectors: protectors)
    }
}
