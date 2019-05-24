//
//  SpinAmountArthitmeticTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class SpinAmountArithmeticTests: XCTestCase {
    func testThatUpSpinTimesPlusOneEqualsPlusOne() {
        let plusOne: PositiveAmount = 1
        XCTAssertEqual(Spin.up * plusOne, 1)
    }
    
    func testThatDownSpinTimesPlusOneEqualsMinusOne() {
        let plusOne: PositiveAmount = 1
        XCTAssertEqual(Spin.down * plusOne, -1)
    }
    
    func testThatUpSpinTimesMinusOneEqualsMinusOne() {
        let minusOne: SignedAmount = -1
        XCTAssertEqual(Spin.up * minusOne, -1)
    }
    
    func testThatDownSpinTimesMinusOneEqualsPlusOne() {
        let minusOne: SignedAmount = -1
        XCTAssertEqual(Spin.down * minusOne, 1)
    }
}
