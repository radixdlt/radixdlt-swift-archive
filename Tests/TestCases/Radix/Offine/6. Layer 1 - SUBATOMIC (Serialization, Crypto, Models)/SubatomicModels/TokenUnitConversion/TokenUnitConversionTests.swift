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
    
    func testDecimalInAttoThrows() {
        XCTAssertThrowsSpecificError(
            try TokenAmount(decimal: 0.1, denomination: .atto),
            TokenAmount.Error.decimalToAttoNotRepresentableAsInteger(decimal: 0.1, denomination: .atto)
        )
    }
    
    func testDecimalThrows() throws {
        let e⁻4: Decimal = 0.0001
        XCTAssertThrowsSpecificError(
            try TokenAmount(decimal: e⁻4, denomination: .femto),
            TokenAmount.Error.decimalToAttoNotRepresentableAsInteger(decimal: e⁻4, denomination: .femto)
        )
        XCTAssertEqual(
            try XCTUnwrap(try? TokenAmount(decimal: e⁻4, denomination: .pico)),
            try XCTUnwrap(try? TokenAmount(decimal: 100, denomination: .atto))
        )
    }
    
    func testFo() throws {
        let dec = try XCTUnwrap(Decimal(string: ".01"))
        XCTAssertEqual(dec, 0.01)
    }
    
    func testBoo() {
        let string = "123"
        let components = string.components(separatedBy: ".")
        XCTAssertEqual(components.count, 1)
        XCTAssertEqual(components[0], string)
    }
    
    func testDecimalStringIntegerButWithTrailingDecimalZeros() {
        func doTest(_ string: String, expectInteger: Bool = true) {
            let components = string.components(separatedBy: ".")
            XCTAssertEqual(components.count, 2)
            guard let decimalFromString = Decimal(string: components[1]) else {
                return XCTFail("failed to create decimal from string")
            }
            let beIntString = expectInteger ? "be" : "_NOT_ be"
            let isZero = decimalFromString == .zero
            XCTAssertEqual(isZero, expectInteger, "Expected decimal string: '\(decimalFromString)' to \(beIntString) and integer, but got result: <isInt: \(isZero)>")
        }

        doTest("1.0")
        doTest("1.00")
        doTest("1.000")
        doTest("1.0000")
        doTest("1.1", expectInteger: false)
        doTest("1.01", expectInteger: false)
    }
    
    func testDecimalLotsOfZeros() throws {
        let lhs = try XCTUnwrap(
            try? TokenAmount(
                decimal: 0.000000000000000000000000000000000001,
                denomination: .exa
            )
        )
        
        let rhs = TokenAmount(
            positiveAmount: 1,
            denomination: .atto
        )
        XCTAssertEqual(lhs, rhs)
    }
    
    func testBigInAttoEqBigInAtto() {
        let amount: PositiveAmount = "123456789012345678901234567890123456"
        XCTAssertEqual(
            TokenAmount(
                positiveAmount: amount,
                denomination: .atto
            ),
            TokenAmount(
                positiveAmount: amount,
                denomination: .atto
            )
        )
    }
    
    func testBigInExaEqBigInExa() {
        XCTAssertEqual(
            try! TokenAmount(
                decimal: 0.123456789012345678901234567890123456,
                denomination: .exa
            ),
            try! TokenAmount(
                decimal: 0.123456789012345678901234567890123456,
                denomination: .exa
            )
        )
    }
        
    func testDecimalLotsOfDigits() throws {
        let lhs = try! TokenAmount(
            decimal: 0.010203040506070809101112131415161718,
            denomination: .exa
        )
        
        let rhs = TokenAmount(
            positiveAmount: "10203040506070809101112131415161718",
            denomination: .atto
        )
        XCTAssertEqual(lhs, rhs)
    }
    
    func testNoThrowFromExa() {
        XCTAssertNoThrow( try TokenAmount(
            decimal: 0.123456789012345678901234567890123456,
            denomination: .exa
        )
        )
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
        
    func testFromWhole() {
        let amount = TokenAmount(positiveAmount: 237, denomination: .whole)
        let amountInAtto = TokenAmount(positiveAmount: "237000000000000000000", denomination: .atto)
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
    
    func testTokenAmountComparableGreaterThan() {
        XCTAssertGreaterThan(
            TokenAmount(positiveAmount: 2, denomination: .whole),
            TokenAmount(positiveAmount: 1, denomination: .whole)
        )
    }
    
    func testTokenAmountComparableLessThan() {
        XCTAssertLessThan(
            TokenAmount(positiveAmount: 2, denomination: .whole),
            TokenAmount(positiveAmount: 3, denomination: .whole)
        )
    }
    
}
