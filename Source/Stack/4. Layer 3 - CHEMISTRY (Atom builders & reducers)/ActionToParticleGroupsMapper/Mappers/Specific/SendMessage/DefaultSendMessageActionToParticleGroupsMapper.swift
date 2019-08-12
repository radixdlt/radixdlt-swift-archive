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

public final class DefaultSendMessageActionToParticleGroupsMapper: SendMessageActionToParticleGroupsMapper {
    public typealias KeyGenerator = () -> KeyPair
    
    private let generateSharedKey: KeyGenerator
    private let encryptedPayloadJsonEncoder: JSONEncoder
    
    public init(
        sharedKeyGenerator: @escaping @autoclosure () -> KeyPair = KeyPair.init(),
        encryptedPayloadJsonEncoder: JSONEncoder = JSONEncoder()
    ) {
        self.generateSharedKey = sharedKeyGenerator
        self.encryptedPayloadJsonEncoder = encryptedPayloadJsonEncoder
    }
}

public extension DefaultSendMessageActionToParticleGroupsMapper {

    func particleGroups(for action: SendMessageAction, addressOfActiveAccount: Address) throws -> ParticleGroups {
        guard action.sender == addressOfActiveAccount else {
            throw Error.nonMatchingAddress(activeAddress: addressOfActiveAccount, butActionStatesAddress: action.sender)
        }
        
        var particles = [AnySpunParticle]()

        let (payload, encryptorParticle) = try encryptDataIfNeeded(action: action)
        
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
    
    func encryptDataIfNeeded(action sendMessageAction: SendMessageAction) throws -> (data: Data, encryptorParticle: AnySpunParticle?) {
        var encryptorParticle: AnySpunParticle?
        let payload: Data = try !sendMessageAction.shouldBeEncrypted ? sendMessageAction.payload : {
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
        }()
        
        return (data: payload, encryptorParticle: encryptorParticle)
    }
}
