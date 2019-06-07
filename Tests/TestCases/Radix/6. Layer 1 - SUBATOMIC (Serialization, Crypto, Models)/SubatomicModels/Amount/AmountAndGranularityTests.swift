//
//  AmountAndGranularityTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-06-06.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class AmountAndGranularityTests: XCTestCase {
    
    private let granularityOfOne: Granularity = 1
    private let granularityOfTwo: Granularity = 2
    private let granularityOfThree: Granularity = 3
    private let granularityOfFour: Granularity = 4
    
    func testGranularityOfOneSignedAmount() {
        func doTest(_ signedAmount: SignedAmount) {
            XCTAssertTrue(signedAmount.isExactMultipleOfGranularity(granularityOfOne))
        }
        doTest(-3)
        doTest(-2)
        doTest(-1)
        doTest(0)
        doTest(1)
        doTest(2)
        doTest(3)
    }
    
    func testGranularityOfTwoSignedAmount() {
        func okGran(_ signedAmount: SignedAmount) {
            XCTAssertTrue(signedAmount.isExactMultipleOfGranularity(granularityOfTwo))
        }
        func badGran(_ signedAmount: SignedAmount) {
            XCTAssertFalse(signedAmount.isExactMultipleOfGranularity(granularityOfTwo))
        }
        okGran(-4)
        badGran(-3)
        okGran(-2)
        badGran(-1)
        okGran(0)
        badGran(1)
        okGran(2)
        badGran(3)
        okGran(4)
    }
    
    func testGranularityOfOneNonNegativeAmount() {
        func doTest(_ signedAmount: NonNegativeAmount) {
            XCTAssertTrue(signedAmount.isExactMultipleOfGranularity(granularityOfOne))
        }
        doTest(0)
        doTest(1)
        doTest(2)
        doTest(3)
    }
    
    func testGranularityOfTwoNonNegativeAmount() {
        func okGran(_ signedAmount: NonNegativeAmount) {
            XCTAssertTrue(signedAmount.isExactMultipleOfGranularity(granularityOfTwo))
        }
        func badGran(_ signedAmount: NonNegativeAmount) {
            XCTAssertFalse(signedAmount.isExactMultipleOfGranularity(granularityOfTwo))
        }
        okGran(0)
        badGran(1)
        okGran(2)
        badGran(3)
        okGran(4)
    }
    
    func testGranularityOfOnePostiveAmount() {
        func doTest(_ signedAmount: PositiveAmount) {
            XCTAssertTrue(signedAmount.isExactMultipleOfGranularity(granularityOfOne))
        }
        doTest(1)
        doTest(2)
        doTest(3)
    }
    
    func testGranularityOfThreePostiveAmount() {
        func okGran(_ signedAmount: PositiveAmount) {
            XCTAssertTrue(signedAmount.isExactMultipleOfGranularity(granularityOfThree))
        }
        func badGran(_ signedAmount: PositiveAmount) {
            XCTAssertFalse(signedAmount.isExactMultipleOfGranularity(granularityOfThree))
        }
        badGran(1)
        badGran(2)
        okGran(3)
        badGran(4)
        badGran(5)
        okGran(6)
        badGran(299)
        okGran(300)
        badGran(301)
        okGran(303)
    }
    
    func testMaxGran() {
        func okGran(_ signedAmount: PositiveAmount) {
            XCTAssertTrue(signedAmount.isExactMultipleOfGranularity(Granularity.max))
        }
        func badGran(_ signedAmount: PositiveAmount) {
            XCTAssertFalse(signedAmount.isExactMultipleOfGranularity(Granularity.max))
        }
        okGran(Granularity.subunitsDenominator)
        badGran(1)
    }
}
