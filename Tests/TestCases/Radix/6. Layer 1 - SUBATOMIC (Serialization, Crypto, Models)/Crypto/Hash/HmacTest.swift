//
//  HmacTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest
@testable import RadixSDK

class ECIESHmacCalculationTests: XCTestCase {
    
    func testHmacCalc() {
        let bytes16: HexString = "1234567890ABCDEF1234567890ABCDEF"
        
        guard let bytes32 = XCTAssertNotThrows(
            try HexString(hexString: bytes16.stringValue + bytes16.stringValue)
        ) else { return }
        
        guard let privateKey = XCTAssertNotThrows(
             try PrivateKey(hex: bytes32)
        ) else { return }
        
        let keyPair = KeyPair(private: privateKey)
        let publicKey = keyPair.publicKey
        
        XCTAssertEqual(
            publicKey.hex,
            "02bb50e2d89a4ed70663d080659fe0ad4b9bc3e06c17a227433966cb59ceee020d",
            "It should work like the Java library"
        )
        
        let keyM = bytes32
        let iv = bytes16
        let cipherText = "A super duper mega secret string"
        let cipherTextEncoded = cipherText.toData()
        XCTAssertEqual(cipherText.length, 32)
        
        guard let mac = XCTAssertNotThrows(
            try ECIES.calculateMAC(salt: keyM, initializationVector: iv, ephemeralPublicKey: publicKey, cipherText: cipherTextEncoded)
        ) else { return }
        
        XCTAssertEqual(
            mac.hex,
            "277ec636418da1504cccffcc699d7f95b5ee3ec09e425494460f7f21139fb74a",
            "It should work like the Java library"
        )
    }
    
}
