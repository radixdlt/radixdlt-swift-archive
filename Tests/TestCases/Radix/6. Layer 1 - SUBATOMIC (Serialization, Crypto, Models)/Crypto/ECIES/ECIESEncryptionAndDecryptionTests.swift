//
//  ECIESEncryptionAndDecryptionTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest
@testable import RadixSDK

class ECIESEncryptionAndDecryptionTests: XCTestCase {
    
    func testAliceCanDecryptMessageMeantForHerEncryptedByBob() {
        struct Bob: PublicKeyOwner {
            private let alicePublicKey: PublicKey
            var publicKey: PublicKey { return alicePublicKey }
            static func receiving(alicePublicKey: PublicKey) -> Bob {
                return Bob(alicePublicKey: alicePublicKey)
            }
        }
        
        // GIVEN
        // Alice and Bob have a keypair each, and a plain text message
        let alice = KeyPair()
        let bob = Bob.receiving(alicePublicKey: alice.publicKey)
        let message = "Hello Radix"
        
        // WHEN
        // Bob encrypts message using Alice public key
        guard let encryptedByBob = XCTAssertNotThrows(
            try bob.encrypt(text: message)
        ) else { return }
        
        // THEN
        XCTAssertNotThrowsAndEqual(
            try alice.decryptAndDecode(encryptedByBob),
            message,
            "Alice can decrypt it"
        )
    }

    func testAliceCannotDecryptMessagesMeantForBobAndViceVersa() {

        // GIVEN
        // Alice and Bob have a keypair each, and a plain text message
        let alice = KeyPair()
        let bob = KeyPair()
        let message = "Hello Radix"
        
        // WHEN
        // Alice encrypts
        guard let encryptedByAlice = XCTAssertNotThrows(
            try alice.encrypt(text: message)
        ) else { return }
        
        // Sanity check that Alice can indeed decode her own message
        XCTAssertNotThrowsAndEqual(
            try alice.decryptAndDecode(encryptedByAlice),
            message
        )
        
        // THEN
        XCTAssertThrowsSpecificError(
            try bob.decrypt(encryptedByAlice),
            ECIES.DecryptionError.macMismatch(expected: .irrelevant, butGot: .irrelevant),
            "Alice should not be able to decode message intended for Bob"
        )
    }
}

extension Data {
    static var irrelevant: Data {
        return .empty
    }
}
