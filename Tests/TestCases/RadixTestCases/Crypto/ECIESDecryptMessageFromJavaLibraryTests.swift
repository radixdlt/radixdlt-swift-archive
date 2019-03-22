//
//  ECIESDecryptMessageFromJavaLibraryTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import RadixSDK

class ECIESDecryptMessageFromJavaLibraryTests: QuickSpec {
    override func spec() {
        describe("ECIES decryption of encrypted message from Java Library") {
            it("should be able to decrypt message for private key 1") {
                do {
                    let encryptedByJava: HexString = "000102030405060708090a0b0c0d0e0f21036d6caac248af96f6afa7f904f550253a0f3ef3f5aa2fe6838a95b216691468e200000010360c3d2fd2eaa6049304361a5dda90728857e21cedd2de6496ddb0174557acb8eaf9ed02c24633a3e9165b3f2d1406b2"
                    let keyPair = KeyPair(private: 1)
                    XCTAssertEqual(keyPair.publicKey.hex, "0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798")
                    let decrypted = try keyPair.decrypt(encryptedByJava)
                    let decodedMessage = String(data: decrypted, encoding: .utf8)!
                    XCTAssertEqual("Hello Radix", decodedMessage)
                } catch {
                    XCTFail("Error: \(error)")
                }
            }
        }
    }
}
