//
//  SignedAmountTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//


import Foundation
@testable import RadixSDK
import XCTest

class SignedAmountTests: XCTestCase {
    
    func testLiteralNegative() {
        let a: SignedAmount = -3
        XCTAssertEqual(a.description, "-3")
    }
    
    func testLiteralPositve() {
        let a: SignedAmount = 3
        XCTAssertEqual(a.description, "3")
    }
    
    func testLiteralZero() {
        let a: SignedAmount = 0
        XCTAssertEqual(a.description, "0")
    }
    
    func testBigSignedInt() {
        // Int64
        let a: SignedAmount = "100000000000000000000000000000000000000000000000000000"
        let b: SignedAmount = 1
        XCTAssertEqual(a + b, "100000000000000000000000000000000000000000000000000001")
    }
    
    
    func testNegatedNegative() {
        let a: SignedAmount = -2
        let negated: SignedAmount = a.negated()
        XCTAssertEqual(negated, 2)
        XCTAssertEqual(negated.negated(), -2)
    }
    
    func testNegatedPositive() {
        let a: SignedAmount = 2
        let negated: SignedAmount = a.negated()
        XCTAssertEqual(negated, -2)
        XCTAssertEqual(negated.negated(), 2)
    }
    
    func testAbsNegative() {
        let a: SignedAmount = -5
        XCTAssertEqual(a.abs, 5)
    }
    
    func testAbsPositive() {
        let a: SignedAmount = 5
        XCTAssertEqual(a.abs, 5)
    }
    
    func testPositiveResultAdd() {
        let a: SignedAmount = 2
        let b: SignedAmount = 3
        XCTAssertEqual(a + b, 5)
    }
    
    func testPositiveResultMultiply() {
        let a: SignedAmount = 2
        let b: SignedAmount = 3
        XCTAssertEqual(a * b, 6)
    }
    
    func testPositiveResultMultiplyTwoNegative() {
        let a: SignedAmount = -2
        let b: SignedAmount = -3
        XCTAssertEqual(a * b, 6)
    }
    
    func testPositiveResultSubtract() {
        let a: SignedAmount = 2
        let b: SignedAmount = 3
        XCTAssertEqual(b - a, 1)
    }
    
    func testPositiveResultAddInout() {
        var a: SignedAmount = 2
        a += 3
        XCTAssertEqual(a, 5)
    }
    
    func testPositiveResultMultiplyInout() {
        var a: SignedAmount = 2
        a *= 5
        XCTAssertEqual(a, 10)
    }
    
    
    func testPositiveResultMultiplyInoutBothNegative() {
        var a: SignedAmount = -2
        a *= -5
        XCTAssertEqual(a, 10)
    }
    
    func testPositiveResultSubtractInout() {
        var a: SignedAmount = 9
        a -= 7
        XCTAssertEqual(a, 2)
    }
    
    func testNegativeResultAdd() {
        let a: SignedAmount = 2
        let b: SignedAmount = -3
        XCTAssertEqual(a + b, -1)
    }
    
    func testNegativeResultMultiply() {
        let a: SignedAmount = 2
        let b: SignedAmount = -3
        XCTAssertEqual(a * b, -6)
    }
    
    func testNegativeResultSubtract() {
        let a: SignedAmount = 2
        let b: SignedAmount = 3
        XCTAssertEqual(a - b, -1)
    }
    
    func testNegativeResultAddInout() {
        var a: SignedAmount = -4
        a += 3
        XCTAssertEqual(a, -1)
    }
    
    func testNegativeResultMultiplyInout() {
        var a: SignedAmount = 2
        a *= -5
        XCTAssertEqual(a, -10)
    }
    
    func testNegativeResultMultiplyInoutNegativeStart() {
        var a: SignedAmount = -2
        a *= 5
        XCTAssertEqual(a, -10)
    }
    
    func testNegativeResultSubtractInout() {
        var a: SignedAmount = 9
        a -= 11
        XCTAssertEqual(a, -2)
    }
}

