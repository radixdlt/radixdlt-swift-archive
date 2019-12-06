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

class DetermineIfPeerIsSuitableTests: TestCase {
    
    func testDefault() throws {
        func doTest(shardSpace: ShardSpace, shards: Shards, expectToBeSuitable: Bool, _ line: UInt = #line) throws {
            let defaultDecisionMaker = DetermineIfPeerIsSuitable.basedOn(
                ifUniverseIsSuitable: .ifEqual(to: UniverseConfig.localnet),
                ifShardsMatchesShardSpace: .default
            )
            
            let host = Host.local(port: 1)
            let node = try Node(host: host, isUsingSSL: false)
            let nodeInfo = NodeInfo(system: RadixSystem(shardSpace: shardSpace), host: host)
            let nodeState = try RadixNodeState(node: node, webSocketStatus: .connected, nodeInfo: nodeInfo, universeConfig: .localnet)
            
            XCTAssertEqual(
                defaultDecisionMaker.isSuitablePeer(state: nodeState, shards: shards),
                expectToBeSuitable,
                "Expected `isPeerSuitable` to return `\(expectToBeSuitable)`, but it did not.",
                line: line
            )
        }
        
        let shardSpace1_2 = try ShardSpace(lower: 1, upperInclusive: 2)
        try doTest(shardSpace: shardSpace1_2, shards: .init(single: 0), expectToBeSuitable: false)
        try doTest(shardSpace: shardSpace1_2, shards: .init(single: 1), expectToBeSuitable: true)
        try doTest(shardSpace: shardSpace1_2, shards: .init(single: 2), expectToBeSuitable: true)
        try doTest(shardSpace: shardSpace1_2, shards: .init(single: 3), expectToBeSuitable: false)
        
        let shardSpace1_3 = try ShardSpace(lower: 1, upperInclusive: 3)
        try doTest(shardSpace: shardSpace1_3, shards: .init(single: 0), expectToBeSuitable: false)
        try doTest(shardSpace: shardSpace1_3, shards: .init(single: 1), expectToBeSuitable: true)
        try doTest(shardSpace: shardSpace1_3, shards: .init(single: 2), expectToBeSuitable: true)
        try doTest(shardSpace: shardSpace1_3, shards: .init(single: 3), expectToBeSuitable: true)
        try doTest(shardSpace: shardSpace1_3, shards: .init(single: 4), expectToBeSuitable: false)
    }

}
