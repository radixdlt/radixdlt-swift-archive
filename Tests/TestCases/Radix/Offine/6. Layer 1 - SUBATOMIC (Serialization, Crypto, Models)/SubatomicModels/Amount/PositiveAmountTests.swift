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

class PositiveAmountTests: XCTestCase {
    func testPositiveAmount256BitMaxValue() {
        XCTAssertEqual(PositiveAmount.max.hex, String(repeating: "f", count: 64))
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
}
