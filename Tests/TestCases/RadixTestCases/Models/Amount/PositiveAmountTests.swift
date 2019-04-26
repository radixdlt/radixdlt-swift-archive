//
//  AmountTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class PostiveAmountTests: XCTestCase {
    func testPositiveAmount256BitMaxValue() {
        XCTAssertEqual(PositiveAmount.maxValue256Bits.hex, String(repeating: "f", count: 64))
    }
    
    func testAdd() {
        let a: PositiveAmount = 2
        let b: PositiveAmount = 3
        XCTAssertEqual(a + b, 5)
    }
    
    func testMultiply() {
        let a: PositiveAmount = 2
        let b: PositiveAmount = 3
        XCTAssertEqual(a * b, 6)
    }
    
    func testSubtract() {
        let a: PositiveAmount = 2
        let b: PositiveAmount = 3
        XCTAssertEqual(b - a, 1)
    }
    
    func testAddInout() {
        var a: PositiveAmount = 2
        a += 3
        XCTAssertEqual(a, 5)
    }
    
    func testMultiplyInout() {
        var a: PositiveAmount = 2
        a *= 5
        XCTAssertEqual(a, 10)
    }
    
    func testSubtractInout() {
        var a: PositiveAmount = 9
        a -= 7
        XCTAssertEqual(a, 2)
    }
    
    func testNegated() {
        let a: PositiveAmount = 3
        let negated: SignedAmount = a.negated()
        XCTAssertEqual(negated, -3)
        XCTAssertEqual(negated.negated(), 3)
    }
    
    func testAbs() {
        let a: PositiveAmount = 3
        XCTAssertEqual(a.abs.magnitude, a.magnitude)
    }
    
    func testThatZeroThrows() {
        XCTAssertThrowsError(try PositiveAmount(validating: 0), "Should not be able to create a Positive amount from `0`") { error in
            guard let amountError = error as? PositiveAmount.Error else {
                return XCTFail("Wrong Error type")
            }
            XCTAssertEqual(amountError, PositiveAmount.Error.amountCannotBeZero)
        }
    }
}
