//
//  SendMessageActionToParticleGroupsMapperTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class SendMessageActionToParticleGroupsMapperTests: XCTestCase {

  
    func testSendMessageEncrypted() {
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let clara = RadixIdentity()
        let diana = RadixIdentity()
        XCTAssertAllInequal(alice, bob, clara, diana)
        
        
        let message = "Hey Bob, this is your friend Alice"
        let sendMessageAction = SendMessageAction(from: alice, to: bob, message: message, shouldBeEncrypted: true)

        let mapper = DefaultSendMessageActionToParticleGroupsMapper {
            [$0.sender, $0.recipient, clara.address].map { $0.publicKey } // Alice => 0, Bob => 1, Clara => 2
        }
        let particleGroups = mapper.particleGroups(for: sendMessageAction)
        XCTAssertEqual(particleGroups.count, 1)
        let particles = particleGroups[0].spunParticles
        XCTAssertEqual(particles.count, 2)
        let spunParticle0 = particles[0]
        let spunParticle1 = particles[1]
        XCTAssertEqual(spunParticle0.spin, .up)
        XCTAssertEqual(spunParticle1.spin, .up)
        
        guard
            let encryptorMessageParticle = spunParticle0.particle as? MessageParticle,
            let messageParticle = spunParticle1.particle as? MessageParticle
        else { return XCTFail("Should both be MessageParticles") }
        
        let protectorsData = encryptorMessageParticle.payload
        let protectorsString = try! JSONDecoder().decode([String].self, from: protectorsData)
        let protectors = protectorsString.map { try! EncryptedPrivateKey(base64String: $0) }

        let encryptedMessage = messageParticle.payload
        
        let aliceProtector = protectors[0]
        let bobProtector = protectors[1]
        let claraProtector = protectors[2]
        
        XCTAssertAllEqual(
            try! alice.decrypt(encryptedMessage, sharedKey: aliceProtector).toString(),
            try! bob.decrypt(encryptedMessage, sharedKey: bobProtector).toString(),
            try! clara.decrypt(encryptedMessage, sharedKey: claraProtector).toString(),
            message
        )

        XCTAssertThrowsSpecificError(
            try alice.decrypt(encryptedMessage, sharedKey: bobProtector),
            ECIES.DecryptionError.macMismatch(expected: .ignored, butGot: .ignored)
        )
        
        // Diana should not be able to decrypt using any message
        for protector in protectors {
            XCTAssertThrowsSpecificError(
                try diana.decrypt(encryptedMessage, sharedKey: protector),
                ECIES.DecryptionError.macMismatch(expected: .ignored, butGot: .ignored)
            )
        }
    }


}

private let magic: Magic = 63799298

private extension RadixIdentity {
    init() {
        self.init(magic: magic)
    }
}

extension Data {
    static var ignored: Data {
        return .empty
    }
}
