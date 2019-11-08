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

class FindANodeEpicGivenWhenThenTests: FindANodeEpicTestCases {

    typealias Given = FindANodeEpic

    // MARK: Test Cases
   
    
    func test_that_we_do_nothing_when_we_have_many_pending_connections() {
        
        given { dependency in
            when_we_have_many_pending_connections(given: dependency) { then, nodeActions in
                then.no_element_can_be_found_in(the: nodeActions)
            }
        }
    }
    func test_that_when_all_peers_are_unsuitable_we_wanna_discover_more() {
        given(
            determineIfPeerIsSuitable: .allPeersAreUnsuitable, // Mock
            determineIfMoreInfoAboutNodeIsNeeded: .neverAskForMoreInfo // Mock
        ) { dependency in
            when_we_know_of_a_single_disconnected_peer(given: dependency) { then, nodeActions, _ in
                then.a_single_DiscoverMoreNodesAction_can_be_found_in(the: nodeActions)
            }
        }
    }
    
    func test_that_when_peers_lack_detailed_data_we_ask_for_it() {
        given(
            determineIfPeerIsSuitable: .allPeersAreUnsuitable // Mock
        ) { dependency in
            when_we_know_of_a_single_disconnected_peer(given: dependency) { then, nodeActions, disconnectedPeer in
                then.a_GetNodeInfo_and_GetUniverseConfig_can_be_found_in(the: nodeActions, forPeer: disconnectedPeer)
            }
        }
    }
    
    func test_that_we_wanna_connected_to_the_single_suitable_peer() {
        given(
            determineIfPeerIsSuitable: .allPeersAreSuitable, // Mock,
            determineIfMoreInfoAboutNodeIsNeeded: .neverAskForMoreInfo // Mock
        ) { dependency in
            when_we_know_of_a_single_disconnected_peer(given: dependency) { then, nodeActions, disconnectedPeer in
                then.a_single_ConnectWebSocketAction_can_be_found_in(the: nodeActions, forPeer: disconnectedPeer)
            }
        }
    }
    
    func test_that_we_wanna_connected_to_the_first_suitable_peer() {
        given(
            radixPeerSelector: .first,
            determineIfPeerIsSuitable: .allPeersAreSuitable, // Mock,
            determineIfMoreInfoAboutNodeIsNeeded: .neverAskForMoreInfo // Mock
        ) { dependency in
            when_we_know_of_two_disconnected_peers(given: dependency) { then, nodeActions, peers in
                XCTAssertEqual(peers.count, 2)
                then.a_single_ConnectWebSocketAction_can_be_found_in(the: nodeActions, forPeer: peers.first!)
            }
        }
    }
    
    func test_that_we_wanna_connected_to_the_last_suitable_peer() {
        given(
            radixPeerSelector: .last,
            determineIfPeerIsSuitable: .allPeersAreSuitable, // Mock,
            determineIfMoreInfoAboutNodeIsNeeded: .neverAskForMoreInfo // Mock
        ) { dependency in
            when_we_know_of_two_disconnected_peers(given: dependency) { then, nodeActions, peers in
                XCTAssertEqual(peers.count, 2)
                then.a_single_ConnectWebSocketAction_can_be_found_in(the: nodeActions, forPeer: peers.last!)
            }
        }
    }
}

// MARK: WHEN
private extension FindANodeEpicGivenWhenThenTests {
    
    func when_network_is_empty(given dependency: Given, fulfil: @escaping (FindANodeEpicGivenWhenThenTests, [NodeAction]) -> Void) {
        when_function_is_called(given: dependency, fulfil)
    }
    func when_we_have_many_pending_connections(given dependency: Given, fulfil: @escaping (FindANodeEpicGivenWhenThenTests, [NodeAction]) -> Void) {
        
        let networkOf2ConnectingNodes: RadixNetworkState = [
            RadixNodeState(node: node1, webSocketStatus: .connecting),
            RadixNodeState(node: node2, webSocketStatus: .connecting)
        ]
        
        when_function_is_called(
            networkState: networkOf2ConnectingNodes,
            given: dependency,
            fulfil
        )
    }
    
    func when_we_know_of_two_disconnected_peers(
        given dependency: Given,
        fulfil: @escaping (FindANodeEpicGivenWhenThenTests, [NodeAction], [Node]) -> Void
    ) {
        let disconnectedPeer1 = RadixNodeState(node: node1, webSocketStatus: .disconnected)
        let disconnectedPeer2 = RadixNodeState(node: node2, webSocketStatus: .disconnected)
        
        when_function_is_called_many_peers(
            networkState: [disconnectedPeer1, disconnectedPeer2],
            given: dependency,
            fulfil
        )
    }
    
    func when_we_know_of_a_single_disconnected_peer(
        given dependency: Given,
        fulfil: @escaping (FindANodeEpicGivenWhenThenTests, [NodeAction], Node) -> Void
    ) {
        let disconnectedPeer = RadixNodeState(node: node1, webSocketStatus: .disconnected)
        
        when_function_is_called(
            networkState: [disconnectedPeer],
            given: dependency,
            peer: disconnectedPeer.node,
            fulfil
        )
    }
}

// MARK: THEN
private extension FindANodeEpicGivenWhenThenTests {
    
    func no_element_can_be_found_in(the nodeActions: [NodeAction], _ line: UInt = #line) {
        XCTAssertTrue(
            nodeActions.isEmpty,
            
            "Expected function to return an empty list of NodeActions when the network contains an amount of nodes with webSocket status 'connecting' that exceeds the maximum allowed limit: '\(FindANodeEpic.maxSimultaneousConnectionRequests)'",
            
            line: line
        )
    }
    
    func a_single_DiscoverMoreNodesAction_can_be_found_in(the nodeActions: [NodeAction], forPeer node: Node? = nil, line: UInt = #line) {
        __weCanFindOneAction(ofType: DiscoverMoreNodesAction.self, inActions: nodeActions, matchingNode: node, line: line)
    }
    
    
    func a_GetNodeInfo_and_GetUniverseConfig_can_be_found_in(the nodeActions: [NodeAction], forPeer node: Node, line: UInt = #line) {

        __weCanFind(
            actionsWithTypes: [GetNodeInfoActionRequest.self, GetUniverseConfigActionRequest.self],
            allMatchingNode: node,
            inActions: nodeActions,
            line: line
        )
    }
    
    func a_single_ConnectWebSocketAction_can_be_found_in(the nodeActions: [NodeAction], forPeer node: Node, line: UInt = #line) {
        __weCanFindOneAction(ofType: ConnectWebSocketAction.self, inActions: nodeActions, matchingNode: node, line: line)
    }
        
    func __weCanFind(
        actionsWithTypes expectedTypes: [NodeAction.Type],
        allMatchingNode node: Node? = nil,
        inActions nodeActions: [NodeAction],
        line: UInt
    ) {
        
        XCTAssertEqual(
            nodeActions.count, expectedTypes.count,
            "Expected number of node actions to be \(expectedTypes.count), but got \(nodeActions.count), namely: \(nodeActions)",
            line: line
        )
        
        for expectedType in expectedTypes {
            XCTAssertTrue(
                nodeActions.contains(where: { Mirror(reflecting: $0).subjectType == expectedType }),
                "Expected node actions to contain a `\(expectedType)`, but it did not, contains: \(nodeActions)",
                line: line
            )
        }
        
        guard let node = node else { return }
        
        for nodeAction in nodeActions {
            XCTAssertEqual(
                nodeAction.node, node,
                "Expected node of action '\(nodeAction)', to equal peer node '\(node)', but was: \(nodeAction.node)",
                line: line
            )
        }
    }
    
    func __weCanFindOneAction<N>(
        ofType type: N.Type,
        inActions nodeActions: [NodeAction],
        matchingNode node: Node? = nil,
        line: UInt
    ) where N: NodeAction {
        
        __weCanFind(
            actionsWithTypes: [N.self],
            allMatchingNode: node,
            inActions: nodeActions,
            line: line
        )
    }
    
}

// MARK: Test utilities
private extension FindANodeEpicGivenWhenThenTests {
    
    func given(
        radixPeerSelector: RadixPeerSelector = .default,
        determineIfPeerIsSuitable: DetermineIfPeerIsSuitable = .default,
        determineIfMoreInfoAboutNodeIsNeeded: DetermineIfMoreInfoAboutNodeIsNeeded = .default,
        _ fulfil: (Given) -> Void
    ) {
        let dependency = Given(
            radixPeerSelector: radixPeerSelector,
            determineIfPeerIsSuitable: determineIfPeerIsSuitable,
            determineIfMoreInfoAboutNodeIsNeeded: determineIfMoreInfoAboutNodeIsNeeded
        )
            
        fulfil(dependency)
    }
    
    func when_function_is_called(
        networkState: RadixNetworkState = .empty,
        shards: Shards = .irrelevant,
        given dependency: Given,
        _ fulfil: (FindANodeEpicGivenWhenThenTests, [NodeAction]) -> Void
    ) {
        
        fulfil(
            self,
            dependency.findAndConnectToSuitablePeer(
                networkState: networkState,
                findANodeRequestAction: FindNodeRequestGivenShards(shards: shards)
            )
        )
    }
    
    func when_function_is_called(
        networkState: RadixNetworkState = .empty,
        shards: Shards = .irrelevant,
        given dependency: Given,
        peer: Node,
        _ fulfil: (FindANodeEpicGivenWhenThenTests, [NodeAction], Node) -> Void
    ) {
        fulfil(
            self,
            dependency.findAndConnectToSuitablePeer(
                networkState: networkState,
                findANodeRequestAction: FindNodeRequestGivenShards(shards: shards)
            ),
            peer
        )
    }

    func when_function_is_called_many_peers(
        networkState: RadixNetworkState = .empty,
        shards: Shards = .irrelevant,
        given dependency: Given,
        _ fulfil: (FindANodeEpicGivenWhenThenTests, [NodeAction], [Node]) -> Void
    ) {
        fulfil(
            self,
            dependency.findAndConnectToSuitablePeer(
                networkState: networkState,
                findANodeRequestAction: FindNodeRequestGivenShards(shards: shards)
            ),
            networkState.nodes.map { $0.key }
        )
    }
    
}
