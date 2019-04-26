//
//  EUIDTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class EUIDTests: XCTestCase {
    
    func testEUIDFrom16Bytes() {
        XCTAssertNotThrowsAndEqual(
            try EUID(Data([Byte](repeating: 0x01, count: 16))),
            "01010101010101010101010101010101",
            "Should have possible to create EUID from 16 bytes"
        )
    }
    
    func testEUIDFrom15BytesThrowsError() {
        XCTAssertThrowsSpecificError(
            try EUID(Data([Byte](repeating: 0x01, count: 15))),
            InvalidStringError.tooFewCharacters(expectedAtLeast: 16, butGot: 15),
            "Should have possible to create EUID from 16 bytes"
        )
    }
    
    func testEUIDFrom16BytesThrowsError() {
        XCTAssertThrowsSpecificError(
            try EUID(Data([Byte](repeating: 0x01, count: 17))),
            InvalidStringError.tooManyCharacters(expectedAtMost: 16, butGot: 17),
            "Should have possible to create EUID from 16 bytes"
        )
    }
}
