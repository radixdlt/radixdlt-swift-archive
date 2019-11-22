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


class NodeInfoEquatableTests: TestCase {

    private let system1_9 = try! RadixSystem(lower: 1, upperInclusive: 9)
    private let system5_15 = try! RadixSystem(lower: 5, upperInclusive: 15)
    private let host42 = Host.local(port: 42)
    private let host237 = Host.local(port: 237)

    func testSameShardSpaceLowRangeSameHost42Equals() {
        XCTAssertEqual(
            NodeInfo(system: system1_9, host: host42),
            NodeInfo(system: system1_9, host: host42)
        )
    }
    
    func testSameShardSpaceLowRangeSameHost237Equals() {
        XCTAssertEqual(
            NodeInfo(system: system1_9, host: host237),
            NodeInfo(system: system1_9, host: host237)
        )
    }
    
    func testSameShardSpaceMidRangeSameHost42Equals() {
        XCTAssertEqual(
            NodeInfo(system: system5_15, host: host42),
            NodeInfo(system: system5_15, host: host42)
        )
    }
    
    func testSameShardSpaceMidRangeSameHost237Equals() {
        XCTAssertEqual(
            NodeInfo(system: system5_15, host: host237),
            NodeInfo(system: system5_15, host: host237)
        )
    }
    
    func testSameShardSpaceLowRangeBothHostNilEquals() {
        XCTAssertEqual(
            NodeInfo(system: system1_9, host: nil),
            NodeInfo(system: system1_9, host: nil)
        )
    }
    
    
    func testDifferentShardSpaceBothHostNilNotEquals() {
        XCTAssertNotEqual(
            NodeInfo(system: system1_9, host: nil),
            NodeInfo(system: system5_15, host: nil)
        )
    }
    
    func testDifferentShardSpaceSameHostNotEquals() {
        XCTAssertNotEqual(
            NodeInfo(system: system1_9, host: host42),
            NodeInfo(system: system5_15, host: host42)
        )
    }
    
    
    func testDifferentShardSpaceDifferentHostNotEquals() {
        XCTAssertNotEqual(
            NodeInfo(system: system1_9, host: host42),
            NodeInfo(system: system5_15, host: host237)
        )
    }
        

}
