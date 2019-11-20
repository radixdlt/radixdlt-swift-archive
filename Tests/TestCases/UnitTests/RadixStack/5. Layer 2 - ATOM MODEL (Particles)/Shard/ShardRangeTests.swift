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


import XCTest
@testable import RadixSDK

class ShardRangeTests: TestCase {
    
    func testOkRange() {
        XCTAssertNoThrow(
            try ShardRange(
                lower: 1,
                upper: 3
            )
        )
    }
    
    func testOutOfRange() {
        XCTAssertThrowsSpecificError(
            try ShardRange(
                lower: 3,
                upper: 1
            ),
            ShardRange.Error.upperMustBeGreaterThanLower
        )
    }
    
    func testSpan() {
        func doTest(lower: Shard, upper: Shard, expectedStride: Shard) {
            do {
                let range = try ShardRange(lower: lower, upper: upper)
                XCTAssertEqual(range.stride, expectedStride)
            } catch {
                XCTFail("bad range")
            }
        }
        doTest(lower: 0, upper: 1, expectedStride: 1)
        doTest(lower: 0, upper: 2, expectedStride: 2)
        doTest(lower: 1, upper: 5, expectedStride: 4)
    }
}
