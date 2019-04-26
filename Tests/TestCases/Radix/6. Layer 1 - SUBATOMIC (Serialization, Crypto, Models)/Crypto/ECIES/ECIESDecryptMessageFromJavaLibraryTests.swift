//
//  ECIESDecryptMessageFromJavaLibraryTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest
@testable import RadixSDK

class ECIESDecryptMessageFromJavaLibraryTests: XCTestCase {
    func testDecryptMessage() {
        // GIVEN
        // The message "Hello Radix", ECIES encrypted by the Java library using the PrivateKey: 1
        let encryptedByJava: HexString = "000102030405060708090a0b0c0d0e0f21036d6caac248af96f6afa7f904f550253a0f3ef3f5aa2fe6838a95b216691468e200000010360c3d2fd2eaa6049304361a5dda90728857e21cedd2de6496ddb0174557acb8eaf9ed02c24633a3e9165b3f2d1406b2"
        
        // WHEN
        // I decrypt it
        guard let decrypted = XCTAssertNotThrows(
            try KeyPair(private: 1).decryptAndDecode(encryptedByJava)
        ) else { return }
        
        // THEN
        // I can read out the original message
        XCTAssertEqual("Hello Radix", decrypted)
    }
}
