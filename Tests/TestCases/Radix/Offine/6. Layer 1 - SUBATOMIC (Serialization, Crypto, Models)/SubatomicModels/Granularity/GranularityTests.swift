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

class GranularityTests: XCTestCase {
    
    func testThatCannotCreateZeroGranularity() {
        XCTAssertThrowsSpecificError(try Granularity(int: 0), Granularity.Error.cannotBeZero)
    }
    
    func testAssertTooLargeThrowsError() {
        
        let expectedError: Granularity.Error = .tooLarge(expectedAtMost: Granularity.subunitsDenominator, butGot: Granularity.subunitsDenominator + 1)
        
        XCTAssertThrowsSpecificError(
            try Granularity(value: Granularity.subunitsDenominator + 1),
            expectedError
        )
    }
    
    func testGranularityToHex() {
        // GIVEN
        // A Granularity of 1
        let granularityOfOne: Granularity = 1
        
        // WHEN
        // I convert it into hex
        let granularityOfOneAsHex = granularityOfOne.hex
        
        // THEN
        // Its length is 64
        XCTAssertEqual(
            granularityOfOneAsHex.count,
            64,
            "Encoding must be 64 chars long"
        )
        // and is value is 1 with 63 leading zeros
        XCTAssertEqual(
            granularityOfOneAsHex,
            "0000000000000000000000000000000000000000000000000000000000000001"
        )
    }
    
    func testDsonEncodeGranularityOfOne() {
        // GIVEN
        // A Granularity of 1
        let granularityOfOne: Granularity = 1
        // WHEN
        // I DSON encode that
        guard let dsonHex = dsonHexStringOrFail(granularityOfOne) else { return }
        
        // THEN
        // I get the same results as Java lib
        XCTAssertEqual(
            dsonHex,
            "5821050000000000000000000000000000000000000000000000000000000000000001"
        )
    }
    
    func testDsonEncodeGranularityBig() {
        // GIVEN
        // A big granularity
        let granularity: Granularity = "10000000000000"
        // WHEN
        // I DSON encode that
        guard let dsonHex = dsonHexStringOrFail(granularity) else { return }
        
        // THEN
        // I get the same results as Java lib
        XCTAssertEqual(
            dsonHex,
            "582105000000000000000000000000000000000000000000000000000009184e72a000"
        )
    }
}
