//
//  NonNegativeAmountTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class NonNegativeAmountTests: XCTestCase {
    
    func testNonNegativeAmount256BitMaxValue() {
        XCTAssertEqual(NonNegativeAmount.maxValue256Bits.hex, String(repeating: "f", count: 64))
    }
    
    func testAdd() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 3
        XCTAssertEqual(a + b, 5)
    }
    
    func testAddZero() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 0
        XCTAssertEqual(a + b, a)
    }
    
    func testMultiply() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 3
        XCTAssertEqual(a * b, 6)
    }
    
    func testMultiplyZero() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 0
        XCTAssertEqual(a * b, 0)
    }
    
    func testSubtract() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 3
        XCTAssertEqual(b - a, 1)
    }
    
    func testSubtractZero() {
        let a: NonNegativeAmount = 2
        let b: NonNegativeAmount = 0
        XCTAssertEqual(a - b, a)
    }
    
    
    func testAddInout() {
        var a: NonNegativeAmount = 2
        a += 3
        XCTAssertEqual(a, 5)
    }
    
    func testAddInoutZero() {
        var a: NonNegativeAmount = 2
        a += 0
        XCTAssertEqual(a, 2)
    }
    
    func testMultiplyInout() {
        var a: NonNegativeAmount = 2
        a *= 5
        XCTAssertEqual(a, 10)
    }
    
    
    func testMultiplyInoutZero() {
        var a: NonNegativeAmount = 2
        a *= 0
        XCTAssertEqual(a, 0)
    }
    
    func testSubtractInout() {
        var a: NonNegativeAmount = 9
        a -= 7
        XCTAssertEqual(a, 2)
    }
    
    func testNegated() {
        let a: NonNegativeAmount = 3
        let negated: SignedAmount = a.negated()
        XCTAssertEqual(negated, -3)
        XCTAssertEqual(negated.negated(), 3)
    }
    
    func testNegatedZero() {
        let a: NonNegativeAmount = 0
        let negated: SignedAmount = a.negated()
        XCTAssertAllEqual(
            0,
            negated,
            negated.negated()
        )
    }
    
    func testAbs() {
        let a: NonNegativeAmount = 3
        XCTAssertEqual(a.abs.magnitude, a.magnitude)
    }
  
    func testAbsZero() {
        let a: NonNegativeAmount = 0
        
        XCTAssertAllEqual(
            0,
            a.magnitude,
            a.abs.magnitude
        )
    }
}
