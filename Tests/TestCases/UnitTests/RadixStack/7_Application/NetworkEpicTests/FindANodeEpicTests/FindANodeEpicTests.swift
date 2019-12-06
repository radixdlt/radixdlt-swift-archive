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
import Combine

class FindANodeEpicTests: NetworkEpicTestCase {
    
    func test_that_an_already_connected_and_suitable_node_is_identified() {
           let node1 = makeNode()
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .allPeersAreSuitable,
            radixPeerSelector: .first,
            waitForConnectionDurationInSeconds: 0.1
        )
        
        let expectedNumberOfOutput = 1
        
        doTest(
            epic: findANodeEpic,
            expectedNumberOfOutput: expectedNumberOfOutput,
            input: { actionsSubject, networkStateSubject in
                networkStateSubject.send([RadixNodeState.of(node: node1, webSocketStatus: .connected)])
                actionsSubject.send(FindMeSomeNodeRequest())
        }
        ) { producedOutput in
            XCTAssertEqual(producedOutput.count, expectedNumberOfOutput)
            XCTAssertType(of: producedOutput[0], is: FindANodeResultAction.self)
            XCTAssertEqual(producedOutput[0].node, node1)
        }
    }
    
    func test_that_when_network_is_empty_we_wanna_discover_more_nodes() {
        
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .allPeersAreSuitable,
            radixPeerSelector: .first,
            waitForConnectionDurationInSeconds: 0.1
        )
        
        let expectedNumberOfOutput = 1
        
        doTest(
            epic: findANodeEpic,
            expectedNumberOfOutput: expectedNumberOfOutput,
            input: { actionsSubject, _ in
                actionsSubject.send(FindMeSomeNodeRequest())
        }
        ) { producedOutput in
            XCTAssertEqual(producedOutput.count, expectedNumberOfOutput)
            XCTAssertType(of: producedOutput[0], is: DiscoverMoreNodesAction.self)
        }
    }
    
    func test_that_we_wanna_get_more_info_about_disconnected_peers_we_dont_have_all_info_about() {
        
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .ifShardSpaceIsKnownDisregardingItsValue,
            radixPeerSelector: .first,
            waitForConnectionDurationInSeconds: 0.1
        )
        let node = makeNode()
        let expectedNumberOfOutput = 2
        
        doTest(
            epic: findANodeEpic,
            expectedNumberOfOutput: expectedNumberOfOutput,
            input: { actionsSubject, networkStateSubject in
                networkStateSubject.send([RadixNodeState.disconnected(from: node)])
                actionsSubject.send(FindMeSomeNodeRequest())
        }
        ) { producedOutput in
            XCTAssertEqual(producedOutput.count, expectedNumberOfOutput)
            XCTAssertType(of: producedOutput[0], is: GetNodeInfoActionRequest.self)
            XCTAssertType(of: producedOutput[1], is: GetUniverseConfigActionRequest.self)
            XCTAssertTrue(producedOutput.allSatisfy({ $0.node == node }))
        }
    }
    
    func test_that_we_wanna_connect_to_a_disconnected_suitable_node_() {
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .allPeersAreSuitable,
            radixPeerSelector: .first,
            waitForConnectionDurationInSeconds: 0.1
        )
        let node = makeNode()
        let expectedNumberOfOutput = 1
        
        doTest(
            epic: findANodeEpic,
            expectedNumberOfOutput: expectedNumberOfOutput,
            input: { actionsSubject, networkStateSubject in
                networkStateSubject.send([RadixNodeState.disconnected(from: node)])
                actionsSubject.send(FindMeSomeNodeRequest())
        }
        ) { producedOutput in
            XCTAssertEqual(producedOutput.count, expectedNumberOfOutput)
            XCTAssertType(of: producedOutput[0], is: ConnectWebSocketAction.self)
            XCTAssertEqual(producedOutput[0].node, node)
        }
    }
    
    func test_that_we_wanna_disconnect_from_a_slow_node_and_connect_to_another_one() {
        
        let slowNode = makeNode(index: 1)
        let fastNode = makeNode(index: 2)
        
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .allPeersAreSuitable,
            radixPeerSelector: .prefer(order: [slowNode, fastNode]),
            determineIfMoreInfoAboutNodeIsNeeded: .neverAskForMoreInfo,
            waitForConnectionDurationInSeconds: 0.1
        )
        
        let expectedNumberOfOutput = 4
        
        func emulateWebSockets(
            reactingTo outputtedNodeAction: NodeAction,
            _ nodeActionsSubject: PassthroughSubject<NodeAction, Never>,
            _ networkStateSubject: PassthroughSubject<RadixNetworkState, Never>
        ) {
            guard outputtedNodeAction is ConnectWebSocketAction else { return }
            if outputtedNodeAction.node == slowNode {
                networkStateSubject.send(
                    [
                        RadixNodeState.of(node: slowNode, webSocketStatus: .connecting),
                        RadixNodeState.of(node: fastNode, webSocketStatus: .disconnected),
                    ]
                )
            } else {
                networkStateSubject.send(
                    [
                        RadixNodeState.of(node: slowNode, webSocketStatus: .connecting),
                        RadixNodeState.of(node: fastNode, webSocketStatus: .connected),
                    ]
                )
            }
        }
        
        doTest(
            epic: findANodeEpic,
            resultingPublisherTransformation: { actionSubject, networkStateSubject, output in
                output
                    .receive(on: RadixSchedulers.mainThreadScheduler) /* Important to receive:on:RadixSchedulers.mainThreadScheduler */
                    .handleEvents(
                        receiveOutput: {
                            emulateWebSockets(reactingTo: $0, actionSubject, networkStateSubject)
                        }
                    )
                    .prefix(expectedNumberOfOutput).eraseToAnyPublisher()
            },
            input: { actionsSubject, networkStateSubject in
                networkStateSubject.send([
                    RadixNodeState.disconnected(from: slowNode),
                    RadixNodeState.disconnected(from: fastNode)
                ])
                actionsSubject.send(FindMeSomeNodeRequest())
        }
        ) { producedOutput in
            XCTAssertEqual(producedOutput.count, expectedNumberOfOutput)
            
            let action0 = producedOutput[0]
            XCTAssertType(of: action0, is: ConnectWebSocketAction.self)
            XCTAssertEqual(action0.node, slowNode)
            
            let action1 = producedOutput[1]
            XCTAssertType(of: action1, is: ConnectWebSocketAction.self)
            XCTAssertEqual(action1.node, fastNode)
            
            let action2 = producedOutput[2]
            XCTAssertType(of: action2, is: FindANodeResultAction.self)
            XCTAssertEqual(action2.node, fastNode)
            
            let action3 = producedOutput[3]
            XCTAssertType(of: action3, is: CloseWebSocketAction.self)
            XCTAssertEqual(action3.node, slowNode)
        }
    }
    
    
    func test_that_when_first_node_fails__then_second_node_should_connect() {
        let failingNode = makeNode(index: 1)
        let goodNode = makeNode(index: 2)
        
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .allPeersAreSuitable,
            radixPeerSelector: .prefer(order: [failingNode, goodNode]),
            determineIfMoreInfoAboutNodeIsNeeded: .neverAskForMoreInfo,
            waitForConnectionDurationInSeconds: 0.1
        )
        let expectedNumberOfOutput = 4
        
        func emulateWebSockets(
            reactingTo outputtedNodeAction: NodeAction,
            _ nodeActionsSubject: PassthroughSubject<NodeAction, Never>,
            _ networkStateSubject: PassthroughSubject<RadixNetworkState, Never>
        ) {
            guard outputtedNodeAction is ConnectWebSocketAction else { return }
            if outputtedNodeAction.node == failingNode {
                networkStateSubject.send(
                    [
                        RadixNodeState.of(node: failingNode, webSocketStatus: .failed),
                        RadixNodeState.of(node: goodNode, webSocketStatus: .disconnected)
                    ]
                )
            } else {
                networkStateSubject.send(
                    [
                        RadixNodeState.of(node: failingNode, webSocketStatus: .failed),
                        RadixNodeState.of(node: goodNode, webSocketStatus: .connected)
                    ]
                )
            }
        }
        
        doTest(
            epic: findANodeEpic,
            resultingPublisherTransformation: { actionSubject, networkStateSubject, output in
                output
                    .receive(on: RadixSchedulers.mainThreadScheduler) /* Important to receive:on:RadixSchedulers.mainThreadScheduler */
                    .handleEvents(
                        receiveOutput: {
                            emulateWebSockets(reactingTo: $0, actionSubject, networkStateSubject)
                    }
                )
                    .prefix(expectedNumberOfOutput).eraseToAnyPublisher()
            },
            input: { actionsSubject, networkStateSubject in
                networkStateSubject.send([
                    RadixNodeState.disconnected(from: failingNode),
                    RadixNodeState.disconnected(from: goodNode)
                ])
                actionsSubject.send(FindMeSomeNodeRequest())
        }
        ) { producedOutput in
            XCTAssertEqual(producedOutput.count, expectedNumberOfOutput)
            
            let action0 = producedOutput[0]
            XCTAssertType(of: action0, is: ConnectWebSocketAction.self)
            XCTAssertEqual(action0.node, failingNode)
            
            let action1 = producedOutput[1]
            XCTAssertType(of: action1, is: ConnectWebSocketAction.self)
            XCTAssertEqual(action1.node, goodNode)
            
            let action2 = producedOutput[2]
            XCTAssertType(of: action2, is: FindANodeResultAction.self)
            XCTAssertEqual(action2.node, goodNode)
            
            let action3 = producedOutput[3]
            XCTAssertType(of: action3, is: CloseWebSocketAction.self)
            XCTAssertEqual(action3.node, failingNode)
        }
    }
}

// MARK: Helpers
struct FindMeSomeNodeRequest: FindANodeRequestAction {
    let shards: Shards = .init(single: 1)
}

public extension DetermineIfPeerIsSuitable {
    static var allPeersAreSuitable: DetermineIfPeerIsSuitable { return DetermineIfPeerIsSuitable { _, _ in true } }
    static var allPeersAreUnsuitable: DetermineIfPeerIsSuitable { return DetermineIfPeerIsSuitable { _, _ in false } }
    
    static var ifShardSpaceIsKnownDisregardingItsValue: DetermineIfPeerIsSuitable {
        return DetermineIfPeerIsSuitable { nodeState, _ in nodeState.shardSpace != nil }
    }
}


public extension RadixPeerSelector {
    
    
    static func prefer(order: [Node]) -> RadixPeerSelector {
        return RadixPeerSelector { nodes in
            
            for preferredNode in order {
                
                if nodes.contains(preferredNode) {
                    return preferredNode
                }
            }
            fatalError("not found")
        }
    }
}


struct FindNodeRequestGivenShards: FindANodeRequestAction {
    let shards: Shards
}


extension DetermineIfMoreInfoAboutNodeIsNeeded {
    static var neverAskForMoreInfo: DetermineIfMoreInfoAboutNodeIsNeeded {
        return DetermineIfMoreInfoAboutNodeIsNeeded { _ in false }
    }
    
}

public extension RadixPeerSelector {
    
    static var last: RadixPeerSelector {
        .init { $0.last }
    }
}
