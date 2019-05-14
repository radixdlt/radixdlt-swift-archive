//
//  CompareAnyAmountWithAnyAmountTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest
@testable import RadixSDK

class CompareAnyAmountWithAnyAmountTests: XCTestCase {
    
    private func assertAmountEquals<A, B>(_ a: A, _ b: B) where A: Amount, B: Amount {
        XCTAssertTrue(a == b)
        XCTAssertTrue(a >= b)
        XCTAssertTrue(a <= b)
        
        XCTAssertFalse(a > b)
        XCTAssertFalse(a < b)
    }
    
    private func assertGreaterThan<A, B>(_ a: A, _ b: B) where A: Amount, B: Amount {
        XCTAssertTrue(a > b)
        XCTAssertTrue(a >= b)
        
        XCTAssertFalse(a == b)
        XCTAssertFalse(a <= b)
        XCTAssertFalse(a < b)
    }
    
    private func assertLessThan<A, B>(_ a: A, _ b: B) where A: Amount, B: Amount {
        XCTAssertTrue(a < b)
        XCTAssertTrue(a <= b)
        
        XCTAssertFalse(a == b)
        XCTAssertFalse(a >= b)
        XCTAssertFalse(a > b)
    }
    
    func testCompareSignedAmountMinus1WithSignedAmountMinus1() {
        let a: SignedAmount = -1
        let b: SignedAmount = -1
        assertAmountEquals(a, b)
    }
    
    func testCompareSignedAmountPlus1WithSignedAmountPlus1() {
        let a: SignedAmount = 1
        let b: SignedAmount = 1
        assertAmountEquals(a, b)
    }
    
    func testComparePositiveAmountPlus1WithPositiveAmountPlus1() {
        let a: PositiveAmount = 1
        let b: PositiveAmount = 1
        assertAmountEquals(a, b)
    }
    
    func testCompareNonNegativeAmountPlus1WithNonNegativeAmountPlus1() {
        let a: NonNegativeAmount = 1
        let b: NonNegativeAmount = 1
        assertAmountEquals(a, b)
    }
    
    func testCompareNonNegativeAmountPlus1WithPositiveAmountPlus1() {
        let a: NonNegativeAmount = 1
        let b: PositiveAmount = 1
        assertAmountEquals(a, b)
    }
    
    func testCompareNonNegativeAmountPlus2WithPositiveAmountPlus1() {
        let a: NonNegativeAmount = 2
        let b: PositiveAmount = 1
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testCompareNonNegativeAmountZeroWithPositiveAmountPlus1() {
        let a: NonNegativeAmount = 0
        let b: PositiveAmount = 1
        assertGreaterThan(b, a)
        assertLessThan(a, b)
    }
    
    func testComparePositiveAmountZeroWithNonNegativeAmountPlus1() {
        let a: PositiveAmount = 0
        let b: NonNegativeAmount = 1
        assertGreaterThan(b, a)
        assertLessThan(a, b)
    }
    
    func testComparePositiveAmountPlus2WithNonNegativeAmountPlus1() {
        let a: PositiveAmount = 2
        let b: NonNegativeAmount = 1
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testCompareSignedAmountPlus1WithPositiveAmountPlus1() {
        let a: SignedAmount = 1
        let b: PositiveAmount = 1
        assertAmountEquals(a, b)
    }
    
    func testComparePositveAmountPlus1WithSignedAmountPlus1() {
        let a: PositiveAmount = 1
        let b: SignedAmount = 1
        assertAmountEquals(a, b)
    }
    
    func testCompareSignedAmountPlus2WithSignedAmountPlus1() {
        let a: SignedAmount = 2
        let b: SignedAmount = 1
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testCompareSignedAmountPlus1WithSignedAmountZero() {
        let a: SignedAmount = 1
        let b: SignedAmount = 0
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testCompareSignedAmountPlus1WithNonNegativeAmountZero() {
        let a: SignedAmount = 1
        let b: NonNegativeAmount = 0
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testCompareSignedAmountPlus1WithSignedAmountMinus1() {
        let a: SignedAmount = 1
        let b: SignedAmount = -1
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testCompareNonNegativeAmountPlus1WithSignedAmountMinus1() {
        let a: NonNegativeAmount = 1
        let b: SignedAmount = -1
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testComparePositiveAmountPlus1WithSignedAmountMinus1() {
        let a: PositiveAmount = 1
        let b: SignedAmount = -1
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testCompareSignedAmountZeroWithSignedAmountMinus1() {
        let a: SignedAmount = 0
        let b: SignedAmount = -1
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testCompareNonNegativeAmountZeroWithSignedAmountMinus1() {
        let a: NonNegativeAmount = 0
        let b: SignedAmount = -1
        assertGreaterThan(a, b)
        assertLessThan(b, a)
    }
    
    func testCompareNonNegativeAmountZeroWithSignedAmountZero() {
        let a: NonNegativeAmount = 0
        let b: SignedAmount = 0
        assertAmountEquals(a, b)
    }
    
    func testCompareSignedAmountZeroWithNonNegativeAmountZero() {
        let a: SignedAmount = 0
        let b: NonNegativeAmount = 0
        assertAmountEquals(a, b)
    }
}
