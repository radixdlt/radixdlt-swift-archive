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
                    let encoding: String.Encoding = .utf8
                    let encodedMessage = message.data(using: encoding)!
                    let encrypted = try keyPair.encrypt(encodedMessage)
                    XCTAssertGreaterThan(encrypted.length, 0)
                    let decrypted = try keyPair.decrypt(encrypted)
                    let decodedMessage = String(data: decrypted, encoding: encoding)!
                    XCTAssertEqual(decodedMessage, message)
                } catch {
                    XCTFail("Error: \(error)")
                }
            }
        }
    }
}
