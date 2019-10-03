//
// MIT License
//
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
@testable import RadixSDK
import XCTest

class TokenUnitConversionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = true
    }
    
    
    func testDecimalLotsOfZeros() throws {
        let lhs = try PositiveAmount(
            string: "0.000000000000000000000000000000000001",
            denomination: .exa
        )
        
        let rhs = try PositiveAmount(
            magnitude: 1,
            denomination: .atto
        )
        XCTAssertEqual(lhs, rhs)
    }
    

    func test1Eminus72baseE54() throws {
        let lhs = try PositiveAmount(
            string: "0.000000000000000000000000000000000000000000000000000000000000000000000001",
            denomination: .exponent(of: 54, nameIfUnknown: "E54", symbolIfUnknown: "BIG")
        )
        
        let rhs = try PositiveAmount(
            magnitude: 1,
            denomination: .atto
        )
        XCTAssertEqual(lhs, rhs)
    }
    
    func testDecimalLotsOfZeros60() throws {
        let lhs = try PositiveAmount(
            string: "0.000000000000000000000000000000000000000000000000000000000001",
            denomination: .exponent(of: 42, nameIfUnknown: "E42", symbolIfUnknown: "BIG")
        )
        
        let rhs = try PositiveAmount(
            magnitude: 1,
            denomination: .atto
        )
        XCTAssertEqual(lhs, rhs)
    }
    
    
    
    func testBigInAttoEqBigInAtto() throws {
        let amount: PositiveAmount.Magnitude = "123456789012345678901234567890123456"
        XCTAssertEqual(
            try PositiveAmount(
                magnitude: amount,
                denomination: .atto
            ),
            try PositiveAmount(
                magnitude: amount,
                denomination: .atto
            )
        )
    }
    
    func testBigInExaEqBigInExa() throws {
        XCTAssertEqual(
            try PositiveAmount(
                string: "0.123456789012345678901234567890123456",
                denomination: .exa
            ),
            try PositiveAmount(
                string: "0.123456789012345678901234567890123456",
                denomination: .exa
            )
        )
    }
    
    func testExaToAtto36Decimals() throws {
        XCTAssertEqual(
            try PositiveAmount(
                string: "0.123456789012345678901234567890123456",
                denomination: .exa
            ),
            try PositiveAmount(magnitude: "123456789012345678901234567890123456", denomination: .atto)
        )
    }
    
    func testExaToAtto35Decimals() throws {
        XCTAssertEqual(
            try PositiveAmount(
                string: "1.23456789012345678901234567890123456",
                denomination: .exa
            ),
            try PositiveAmount(magnitude: "1234567890123456789012345678901234560", denomination: .atto)
        )
    }
    
    
    func testTooManyDecimalThrows() throws {
        let amountString = "0.0123456789012345678901234567890123456"
        XCTAssertThrowsSpecificError(
            try PositiveAmount(string: amountString, denomination: .exa),
            PositiveAmount.Error.amountFromStringNotRepresentableInDenomination(amountString: amountString, specifiedDenomination: .exa)
        )
    }
    
    func testThatUsingDecimalStringForAttoResultsInErrorThrown() throws {
        XCTAssertThrowsSpecificError(
            try PositiveAmount(string: "0.1", denomination: .atto),
            PositiveAmount.Error.amountFromStringNotRepresentableInDenomination(amountString: "0.1", specifiedDenomination: .atto)
        )
    }
    
    func testThatUsingDoubleForAttoResultsInErrorThrown() throws {
        XCTAssertThrowsSpecificError(
            // We expect a compilation warning below
            try PositiveAmount(double: 0.1, denomination: .atto),
            PositiveAmount.Error.amountInAttoIsOnlyMeasuredInIntegers(butPassedDouble: 0.1)
        )
    }
    
    func testDecimalLotsOfDigits() throws {
        let lhs = try PositiveAmount(
            string: "0.010203040506070809101112131415161718",
            denomination: .exa
        )
        
        let rhs = try PositiveAmount(
            magnitude: "10203040506070809101112131415161718",
            denomination: .atto
        )
        XCTAssertEqual(lhs, rhs)
    }
        
    func testDenominatorContent() {
        Denomination.allCases.forEach { print($0.debugDescription) }
        
        func doTest(_ denomination: Denomination, expectedExponent: Int, expectedName: String) {
            XCTAssertEqual(denomination.exponent, expectedExponent)
            XCTAssertEqual(denomination.name, expectedName)
        }
        
        doTest(.atto, expectedExponent: -18, expectedName: "atto")
        doTest(.femto, expectedExponent: -15, expectedName: "femto")
        doTest(.pico, expectedExponent: -12, expectedName: "pico")
        doTest(.nano, expectedExponent: -9, expectedName: "nano")
        doTest(.micro, expectedExponent: -6, expectedName: "micro")
        doTest(.milli, expectedExponent: -3, expectedName: "milli")
        doTest(.centi, expectedExponent: -2, expectedName: "centi")
        doTest(.deci, expectedExponent: -1, expectedName: "deci")
        doTest(.whole, expectedExponent: 0, expectedName: "whole")
        doTest(.deca, expectedExponent: 1, expectedName: "deca")
        
    }
    
    func testFromWhole() throws {
        let amount = try PositiveAmount(magnitude: 237, denomination: .whole)
        let amountInAtto = try PositiveAmount(magnitude: "237000000000000000000", denomination: .atto)
        XCTAssertEqual(amount, amountInAtto)
        XCTAssertFalse(amount > amountInAtto)
        XCTAssertFalse(amount < amountInAtto)
        
        let a236Whole: PositiveAmount = "236000000000000000000"
        let a237Whole: PositiveAmount = "237000000000000000000"
        let a238Whole: PositiveAmount = "238000000000000000000"
        
        XCTAssertTrue(amount == a237Whole)
        XCTAssertTrue(amount != a236Whole)
        XCTAssertTrue(amount != a238Whole)
        XCTAssertFalse(amount != a237Whole)
        XCTAssertTrue(amount > a236Whole)
        XCTAssertTrue(amount < a238Whole)
        
        XCTAssertTrue(a237Whole == amount)
        XCTAssertTrue(a236Whole != amount)
        XCTAssertTrue(a238Whole != amount)
        XCTAssertFalse(a237Whole != amount)
        
        XCTAssertFalse(a237Whole > amount)
        XCTAssertFalse(a237Whole < amount)
        
        XCTAssertFalse(a236Whole > amount)
        XCTAssertTrue(a236Whole < amount)
        XCTAssertFalse(a238Whole < amount)
        XCTAssertTrue(a238Whole > amount)
    }
    
    func testTokenAmountComparableGreaterThan() throws {
        XCTAssertGreaterThan(
            try PositiveAmount(magnitude: 2, denomination: .whole),
            try PositiveAmount(magnitude: 1, denomination: .whole)
        )
    }
    
    func testTokenAmountComparableLessThan() throws {
        XCTAssertLessThan(
            try PositiveAmount(magnitude: 2, denomination: .whole),
            try PositiveAmount(magnitude: 3, denomination: .whole)
        )
    }
    
}
