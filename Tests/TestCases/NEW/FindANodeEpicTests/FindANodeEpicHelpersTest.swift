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

class FindANodeEpicTestCases: TestCase {
    let node1 = makeNode()
    let node2 = makeNode()
}

class FindANodeEpicHelpersTest: FindANodeEpicTestCases {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    // MARK: Empty Network -> DiscoverNode
    
    /// Test that we start discovering more nodes if no are present in our known network
    ///
    /// Human readable version of:
    ///
    ///        // GIVEN
    ///        // a `FindANodeEpic`
    ///
    ///        let epic = FindANodeEpic()
    ///
    ///        // WHEN:
    ///        // helper function is called with an empty network state
    ///
    ///        let nodeActions = epic.helperNextConnectionRequest(shards: .irrelevant, networkState: .empty)
    ///
    ///        // THEN:
    ///        // a single `DiscoverMoreNodesAction` is found
    ///
    ///        XCTAssertEqual(nodeActions.count, 1)
    ///        XCTAssertType(of: nodeActions[0], is: DiscoverMoreNodesAction.self)
    func test_that_next_connection_function_returns_single__DiscoverMoreNodesAction__when_network_state_is_empty() {
        
        // MARK: WHEN
        func when_function_is_called_with_an_empty_network(given nextConnection: NextConnection, fulfil: @escaping ([NodeAction]) -> Void) {
            when_next_connection_is_called(given: nextConnection, fulfil)
        }
        
        // MARK: THEN
        func then_a_single_DiscoverMoreNodesAction_can_be_found_in(the nodeActions: [NodeAction]) {
            XCTAssertEqual(nodeActions.count, 1)
            XCTAssertType(of: nodeActions[0], is: DiscoverMoreNodesAction.self)
        }
        
        // MARK: Given When Then
        given_a_next_connection { nextConnection in
            when_function_is_called_with_an_empty_network(given: nextConnection) { nodeActions in
                then_a_single_DiscoverMoreNodesAction_can_be_found_in(the: nodeActions)
            }
        }
    }
    
    // MARK: Many Connecting -> No Action
    
    func test_that_next_connection_function_returns_empty_list_when_network_state_contains_too_many_connecting_nodes() {
        
        // MARK: WHEN
        func when_function_is_called_with_a_network_state_containing_too_many_connecting_nodes(given nextConnection: NextConnection, fulfil: @escaping ([NodeAction]) -> Void) {
            
            let networkOf2ConnectingNodes: RadixNetworkState = [
                RadixNodeState(node: node1, webSocketStatus: .connecting),
                RadixNodeState(node: node2, webSocketStatus: .connecting)
            ]
            
            when_next_connection_is_called(
                networkState: networkOf2ConnectingNodes,
                given: nextConnection,
                fulfil
            )
        }
        
        // MARK: THEN
        func then_no_element_can_be_found_in(the nodeActions: [NodeAction], _ line: UInt = #line) {
            XCTAssertTrue(
                nodeActions.isEmpty,
                
                "Expected function to return an empty list of NodeActions when the network contains an amount of nodes with websocket status 'connecting' that exceeds the maximum allowed limit: '\(FindANodeEpic.maxSimultaneousConnectionRequests)'",
                
                line: line
            )
        }
        
        // MARK: Given When Then
        given_a_next_connection { nextConnection in
            when_function_is_called_with_a_network_state_containing_too_many_connecting_nodes(given: nextConnection) { nodeActions in
                then_no_element_can_be_found_in(the: nodeActions)
            }
        }
        
    }
    
    // MARK: Con+Clos -> DiscoverNode
    func test_that_next_connection_function_returns_single__DiscoverMoreNodesAction__when_network_contains_1disconnected_and_1connecting_node() {
        
        // MARK: WHEN
        func when_function_is_called_with_a_network_of_1disconnected_1closing_node(given nextConnection: NextConnection, fulfil: @escaping ([NodeAction]) -> Void) {
            
            let networkState: RadixNetworkState = [
                RadixNodeState(node: node1, webSocketStatus: .disconnected),
                RadixNodeState(node: node2, webSocketStatus: .connecting)
            ]
            
            when_next_connection_is_called(
                networkState: networkState,
                given: nextConnection,
                fulfil
            )
        }
        
        // MARK: THEN
        func then_a_single_DiscoverMoreNodesAction_can_be_found_in(the nodeActions: [NodeAction], line: UInt = #line) {
            XCTAssertEqual(nodeActions.count, 1, "Expected number of node actions to be 1, but got \(nodeActions.count), namely: \(nodeActions)", line: line)
            XCTAssertType(of: nodeActions[0], is: DiscoverMoreNodesAction.self, line: line)
        }
        
        // MARK: Given When Then
        given_a_next_connection { nextConnection in
            when_function_is_called_with_a_network_of_1disconnected_1closing_node(given: nextConnection) { nodeActions in
                then_a_single_DiscoverMoreNodesAction_can_be_found_in(the: nodeActions)
            }
        }
    }
}


extension FindANodeEpicHelpersTest {
    
    func given_a_next_connection(_ fulfil: (NextConnection) -> Void) {
        fulfil(NextConnection())
    }
    
    func when_next_connection_is_called(
        networkState: RadixNetworkState = .empty,
        shards: Shards = .irrelevant,
        given nextConnection: NextConnection,
        _ fulfil: ([NodeAction]) -> Void
    ) {
        fulfil(nextConnection.nextConnection(shards: shards, networkState: networkState))
    }
}

//extension FindANodeEpicTestCases {
//
//
//    func when_calling<InA, Out>(
//        function: (FindANodeEpic) -> (InA) -> Out,
//        with argument: InA,
//        given epic: FindANodeEpic,
//        _ fulfil: (Out) -> Void
//    ) {
//        let returnValue: Out = function(epic)(argument)
//        fulfil(returnValue)
//    }
//
//    func when_calling<InA, InB, Out>(
//        function: (FindANodeEpic) -> (InA, InB) -> Out,
//        with argumentA: InA,
//        andWith argumentB: InB,
//        given epic: FindANodeEpic,
//        _ fulfil: (Out) -> Void
//    ) {
//        let returnValue: Out = function(epic)(argumentA, argumentB)
//        fulfil(returnValue)
//    }
//
//}

extension RadixNetworkState {
    static var empty: Self { .init() }
}

extension Shards {
    static var irrelevant: Self { .init(single: .irrelevant) }
}

var nextNode: UInt8 = 1
func makeNode() -> Node {
    defer { nextNode += 1 }
    return try! Node(domain: "1.1.1.\(nextNode)", port: 1, isUsingSSL: false)
}
