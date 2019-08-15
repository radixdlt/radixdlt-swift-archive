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
