//
//  ECIESEncryptionAndDecryptionTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import RadixSDK

class ECIESEncryptionAndDecryptionTests: QuickSpec {
    override func spec() {
        describe("ECIES encryption for generated key pair") {
            it("should decrypt encrypted messages") {
                do {
                    let alice = KeyPair()
                    let bob = KeyPair()
                    let message = "Hello Radix"
                    let encryptedByAlice = expectNoErrorToBeThrown { try alice.encrypt(text: message) }
                    let encryptedByBob = expectNoErrorToBeThrown { try bob.encrypt(text: message) }
                    
                    expect { try alice.decrypt(encryptedByBob) }.to(throwError(ECIES.DecryptionError.macMismatch(expected: .empty, butGot: .empty)))
                    expect { try bob.decrypt(encryptedByAlice) }.to(throwError(ECIES.DecryptionError.macMismatch(expected: .empty, butGot: .empty)))
                    
                    let decrypted = try alice.decryptAndDecode(encryptedByAlice)
                    expect(decrypted).to(equal(message))
                    expect(try bob.decryptAndDecode(encryptedByBob)).to(equal(decrypted))
                } catch {
                    XCTFail("Error: \(error)")
                }
            }
        }
    }
}
