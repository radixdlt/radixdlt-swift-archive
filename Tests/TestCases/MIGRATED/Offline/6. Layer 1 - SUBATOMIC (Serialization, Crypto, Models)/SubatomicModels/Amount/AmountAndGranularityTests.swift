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

class AmountAndGranularityTests: XCTestCase {
    
    private let granularityOfOne: Granularity = 1
    private let granularityOfTwo: Granularity = 2
    private let granularityOfThree: Granularity = 3
    private let granularityOfFour: Granularity = 4

    func testGranularityOfOneNonNegativeAmount() {
        func doTest(_ signedAmount: NonNegativeAmount) {
            XCTAssertTrue(signedAmount.isMultiple(of: granularityOfOne))
        }
        doTest(0)
        doTest(1)
        doTest(2)
        doTest(3)
    }
    
    func testGranularityOfTwoNonNegativeAmount() {
        func okGran(_ signedAmount: NonNegativeAmount) {
            XCTAssertTrue(signedAmount.isMultiple(of: granularityOfTwo))
        }
        func badGran(_ signedAmount: NonNegativeAmount) {
            XCTAssertFalse(signedAmount.isMultiple(of: granularityOfTwo))
        }
        okGran(0)
        badGran(1)
        okGran(2)
        badGran(3)
        okGran(4)
    }
    
    func testGranularityOfOnePositiveAmount() {
        func doTest(_ signedAmount: PositiveAmount) {
            XCTAssertTrue(signedAmount.isMultiple(of: granularityOfOne))
        }
        doTest(1)
        doTest(2)
        doTest(3)
    }
    
    func testGranularityOfThreePositiveAmount() {
        func okGran(_ signedAmount: PositiveAmount) {
            XCTAssertTrue(signedAmount.isMultiple(of: granularityOfThree))
        }
        func badGran(_ signedAmount: PositiveAmount) {
            XCTAssertFalse(signedAmount.isMultiple(of: granularityOfThree))
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
    
}
