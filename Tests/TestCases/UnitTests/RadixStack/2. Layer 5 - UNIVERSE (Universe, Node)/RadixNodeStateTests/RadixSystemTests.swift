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

class RadixSystemTests: TestCase {
    
    private let systemShardRange01_09 = try! RadixSystem(lower: 1, upper: 9)
    private let systemShardRange10_20 = try! RadixSystem(lower: 10, upper: 20)
    private let systemShardRange5_15 = try! RadixSystem(lower: 5, upper: 15)

    func testSameShardSpaceLowRangeEquals() {
        XCTAssertEqual(
            systemShardRange01_09,
            systemShardRange01_09
        )
    }
    
    func testSameShardSpaceMidRangeEquals() {
        XCTAssertEqual(
            systemShardRange5_15,
            systemShardRange5_15
        )
    }
    
    func testSameShardSpaceHighRangeEquals() {
        XCTAssertEqual(
            systemShardRange10_20,
            systemShardRange10_20
        )
    }
    
    func testSameShardSpaceLowNotEqualsMid() {
        XCTAssertNotEqual(
            systemShardRange01_09,
            systemShardRange5_15
        )
    }
    
    func testSameShardSpaceLowNotEqualsHigh() {
        XCTAssertNotEqual(
            systemShardRange01_09,
            systemShardRange10_20
        )
    }
    
    
    func testSameShardSpaceMidNotEqualsHigh() {
        XCTAssertNotEqual(
            systemShardRange5_15,
            systemShardRange10_20
        )
    }
}


internal extension ShardSpace {
    
    init(range: ShardRange) throws {
        try self.init(range: range, anchor: range.range.lowerBound)
    }
    
    init(lower: ShardRange.Bound, upper: ShardRange.Bound) throws {
        try self.init(range: ShardRange(lower: lower, upper: upper))
    }
}

internal extension RadixSystem {
    init(lower: ShardRange.Bound, upper: ShardRange.Bound) throws {
        let shardSpace = try ShardSpace(lower: lower, upper: upper)
        self.init(shardSpace: shardSpace)
    }
}
