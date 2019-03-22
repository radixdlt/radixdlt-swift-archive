//
//  HmacTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import RadixSDK

class ECIESHmacCalculationTests: QuickSpec {
    override func spec() {
        describe("Hmac calculation") {
            it("should work like java library") {
                let bytes16: HexString = "1234567890ABCDEF1234567890ABCDEF"
                let bytes32 = try! HexString(hexString: bytes16.stringValue + bytes16.stringValue)
                let privateKey = try! PrivateKey(hex: bytes32)
                let keyPair = KeyPair(private: privateKey)
                let publicKey = keyPair.publicKey
                
                expect(publicKey.hex).to(equal("02bb50e2d89a4ed70663d080659fe0ad4b9bc3e06c17a227433966cb59ceee020d"))
                
                let keyM = bytes32
                let iv = bytes16
                let cipherText = "A super duper mega secret string"
                let encoding: String.Encoding = .utf8
                let cipherTextEncoded = cipherText.data(using: encoding)!
                expect(cipherText.length).to(equal(32))
                
                let mac = try! ECIES.calculateMAC(salt: keyM, initializationVector: iv, ephemeralPublicKey: publicKey, cipherText: cipherTextEncoded)
                expect(mac.hex).to(equal("277ec636418da1504cccffcc699d7f95b5ee3ec09e425494460f7f21139fb74a"))
            }
        }
    }
}
