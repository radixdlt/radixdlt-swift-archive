//
//  DecimalStringTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-06-06.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class DecimalStringTests: XCTestCase {

    func testDecimalString() {
        XCTAssertNoThrow(try DecimalString(string: "1234567890"))
        XCTAssertNoThrow(try DecimalString(string: "0"))
        XCTAssertNoThrow(try DecimalString(string: "1"))
        XCTAssertNoThrow(try DecimalString(string: "2"))
        XCTAssertNoThrow(try DecimalString(string: "3"))
        XCTAssertNoThrow(try DecimalString(string: "4"))
        XCTAssertNoThrow(try DecimalString(string: "5"))
        XCTAssertNoThrow(try DecimalString(string: "6"))
        XCTAssertNoThrow(try DecimalString(string: "7"))
        XCTAssertNoThrow(try DecimalString(string: "8"))
        XCTAssertNoThrow(try DecimalString(string: "9"))
       
        XCTAssertThrowsError(try DecimalString(string: "a"))
        XCTAssertThrowsError(try DecimalString(string: "1b"))
        XCTAssertThrowsError(try DecimalString(string: "2c"))
    }

}
