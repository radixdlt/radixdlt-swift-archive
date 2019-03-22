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

                    let keyPair = KeyPair()
                    let message = "Hello Radix"
                    let encrypted = try keyPair.encrypt(text: message)
                    XCTAssertGreaterThan(encrypted.length, 0)
                    let decrypted = try keyPair.decryptAndDecode(encrypted)
                    XCTAssertEqual(decrypted, message)
                } catch {
                    XCTFail("Error: \(error)")
                }
            }
        }
    }
}
