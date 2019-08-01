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
    
    func testComparePositiveAmountOneWithNonNegativeAmountZero() {
        let a: NonNegativeAmount = 0
        let b: PositiveAmount = 1
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
