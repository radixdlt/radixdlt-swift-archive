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
import Combine

class DiscoverNodesEpicTests: NetworkEpicTestCase {
    

    func test_that_when_seeds_return_a_non_matching_universe__a_node_mismatch_universe_event_should_be_emitted() {
        
        let node = makeNode()
        
        let epic = DiscoverNodesEpic(
            seedNodes: Just(node).eraseToAnyPublisher(),
            isUniverseSuitable: .alwaysMismatch
        )
        
        let expectedNumberOfOutput = 2
        
        doTest(
            epic: epic,
            expectedNumberOfOutput: expectedNumberOfOutput,
            input: { actionsSubject, networkStateSubject in
                actionsSubject.send(DiscoverMoreNodesAction())
                actionsSubject.send(GetUniverseConfigActionResult(node: node, result: .irrelevant))
            },
            
            outputtedNodeActionsHandler: { producedOutput in
                XCTAssertEqual(producedOutput.count, expectedNumberOfOutput)
                XCTAssertType(of: producedOutput[0], is: GetUniverseConfigActionRequest.self)
                XCTAssertType(of: producedOutput[1], is: NodeUniverseMismatch.self)
                XCTAssertTrue(producedOutput.allSatisfy({ $0.node == node }))
            }
        )
    }
    
    func test_that_when_live_peers_result_is_observed__add_node_events_should_be_emitted() {
        let node = makeNode()
        
        let epic = DiscoverNodesEpic(
            seedNodes: Just(node).eraseToAnyPublisher(),
            isUniverseSuitable: .alwaysMatch
        )
        
        let expectedNumberOfOutput = 2
        
        doTest(
            epic: epic,
            expectedNumberOfOutput: expectedNumberOfOutput,
            input: { actionsSubject, networkStateSubject in
                // Duplicates should be removed, so `[.one, .one, .two]` ought to result in `[.one, .two]`
                actionsSubject.send(GetLivePeersActionResult(node: node, result: [.one, .one, .two]))
                networkStateSubject.send(RadixNetworkState.empty)
            },
            
            outputtedNodeActionsHandler: { producedOutput in
                print(producedOutput)
                XCTAssertEqual(producedOutput.count, expectedNumberOfOutput)
                XCTAssertType(of: producedOutput[0], is: AddNodeAction.self)
                XCTAssertType(of: producedOutput[1], is: AddNodeAction.self)
                XCTAssertEqual(producedOutput[0].node.host, Host.local(port: 1))
                XCTAssertEqual(producedOutput[1].node.host, Host.local(port: 2))
            }
        )
    }
}

extension DetermineIfUniverseIsSuitable {
    static let alwaysMismatch = DetermineIfUniverseIsSuitable { _ in false }
    static let alwaysMatch = DetermineIfUniverseIsSuitable { _ in true }
}

extension UniverseConfig {
    static let irrelevant = Self.localnet
}

extension NodeInfo {
    static let one = Self(system: .irrelevant, host: .local(port: 1))
    static let two = Self(system: .irrelevant, host: .local(port: 2))
}

extension RadixSystem {
    static let irrelevant = Self(shardSpace: .irrelevant)
}

extension ShardSpace {
    static let irrelevant = try! Self(range: .irrelevant, anchor: 1)
}

extension ShardRange {
    static let irrelevant: Self =  try! Self(lower: 0, upperInclusive: 2)
}
