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

class FindANodeEpicTestCases: TestCase {
    let node1 = makeNode()
    let node2 = makeNode()
}

class FindANodeEpicTests: FindANodeEpicTestCases {
    
    func test_that_epic_returns_an_already_connected_and_suitable_node() {
        let findMeSomeNodeRequest = FindMeSomeNodeRequest(shards: .init(single: 1))
        
        let waitForConnectionDurationInSeconds: TimeInterval = 0.1
        
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .allPeersAreSuitable,
            radixPeerSelector: .first,
            waitForConnectionDurationInSeconds: waitForConnectionDurationInSeconds
        )
        
        let networkState: RadixNetworkState = [RadixNodeState(node: node1, webSocketStatus: .connected)]
        
        var returnValues = [NodeAction]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let actionsSubject = PassthroughSubject<NodeAction, Never>()
        let networkStateSubject = PassthroughSubject<RadixNetworkState, Never>()
        
        let cancellable = findANodeEpic.epic(
            actions: actionsSubject.eraseToAnyPublisher(),
            networkState: networkStateSubject.eraseToAnyPublisher()
        )
            .receive(on: RunLoop.main)
            .first() // Only care about first
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { returnValues.append($0) }
        )
        
        networkStateSubject.send(networkState)
        actionsSubject.send(findMeSomeNodeRequest)
        
        wait(for: [expectation], timeout: 2 * waitForConnectionDurationInSeconds)
        
        XCTAssertEqual(returnValues.count, 1)
        XCTAssertType(of: returnValues[0], is: FindANodeResultAction.self)
        XCTAssertEqual(returnValues[0].node, node1)
        XCTAssertNotNil(cancellable)
    }
    
    func test_that_empty_network_results_in_discover_more() {
        
        let findMeSomeNodeRequest = FindMeSomeNodeRequest(shards: .init(single: 1))
        
        let waitForConnectionDurationInSeconds: TimeInterval = 0.1
        
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .allPeersAreSuitable,
            radixPeerSelector: .first,
            waitForConnectionDurationInSeconds: waitForConnectionDurationInSeconds
        )
        
        
        var returnValues = [NodeAction]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let actionsSubject = PassthroughSubject<NodeAction, Never>()
        
        let cancellable = findANodeEpic.epic(
            actions: actionsSubject.eraseToAnyPublisher(),
            // we start with a default output (value) of the network state publisher inside implementation, so even if we use `Empty()` publisher here (not outputting any value), we expect the epic to emit a value.
            networkState: Empty().eraseToAnyPublisher()
            ).first() // Only care about first
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { returnValues.append($0) }
        )
        
        actionsSubject.send(findMeSomeNodeRequest)
        
        wait(for: [expectation], timeout: 2 * waitForConnectionDurationInSeconds)
        
        XCTAssertEqual(returnValues.count, 1)
        XCTAssertType(of: returnValues[0], is: DiscoverMoreNodesAction.self)
        XCTAssertNotNil(cancellable)
    }
    
    func test_that_we_wanna_get_more_info_about_disconnected_peers_we_dont_have_all_info_about() {
        
        let findMeSomeNodeRequest = FindMeSomeNodeRequest(shards: .init(single: 1))
        
        let waitForConnectionDurationInSeconds: TimeInterval = 0.1
        
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .ifShardSpaceIsKnownDisregardingItsValue,
            radixPeerSelector: .first,
            waitForConnectionDurationInSeconds: waitForConnectionDurationInSeconds
        )
        
        let node = node1
        let networkState: RadixNetworkState = [RadixNodeState(node: node, webSocketStatus: .disconnected)]
        
        var returnValues = [NodeAction]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let actionsSubject = PassthroughSubject<NodeAction, Never>()
        let networkStateSubject = PassthroughSubject<RadixNetworkState, Never>()
        
        let cancellable = findANodeEpic.epic(
            actions: actionsSubject.eraseToAnyPublisher(),
            networkState: networkStateSubject.eraseToAnyPublisher()
            )
              .receive(on: RunLoop.main)
            .prefix(2) // only care about the first 2
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { returnValues.append($0) }
        )
        
        networkStateSubject.send(networkState)
        actionsSubject.send(findMeSomeNodeRequest)
        
        wait(for: [expectation], timeout: 2 * waitForConnectionDurationInSeconds)
        
        XCTAssertEqual(returnValues.count, 2, "Expected 2 actions, but got: `\(returnValues.count)`, specifically: `\(returnValues)`")
        XCTAssertType(of: returnValues[0], is: GetNodeInfoActionRequest.self)
        XCTAssertType(of: returnValues[1], is: GetUniverseConfigActionRequest.self)
        XCTAssertTrue(returnValues.allSatisfy({ $0.node == node }))
        XCTAssertNotNil(cancellable)
    }
    
    func test_that_we_wanna_connect_to_a_disconnected_suitable_node() {
        
        let findMeSomeNodeRequest = FindMeSomeNodeRequest(shards: .init(single: 1))
        
        
        let waitForConnectionDurationInSeconds: TimeInterval = 0.1
        
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .allPeersAreSuitable,
            radixPeerSelector: .first,
            waitForConnectionDurationInSeconds: waitForConnectionDurationInSeconds
        )
        
        
        var returnValues = [NodeAction]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let actionsSubject = PassthroughSubject<NodeAction, Never>()
        let networkStateSubject = PassthroughSubject<RadixNetworkState, Never>()
        
        let node = node1
        let networkState: RadixNetworkState = [
            RadixNodeState(node: node, webSocketStatus: .disconnected)
        ]
        
        let cancellable = findANodeEpic.epic(
            actions: actionsSubject.eraseToAnyPublisher(),
            networkState: networkStateSubject.eraseToAnyPublisher()
            ).first() // only care about the first
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { returnValues.append($0) }
        )
        
        networkStateSubject.send(networkState)
        actionsSubject.send(findMeSomeNodeRequest)
        
        wait(for: [expectation], timeout: 2*waitForConnectionDurationInSeconds)
        
        XCTAssertEqual(returnValues.count, 1, "Expected 1 actions, but got: `\(returnValues.count)`, specifically: `\(returnValues)`")
        XCTAssertType(of: returnValues[0], is: ConnectWebSocketAction.self)
        XCTAssertEqual(returnValues[0].node, node)
        XCTAssertNotNil(cancellable)
    }
    
    
    func test_that_we_wanna_disconnect_from_a_slow_node_and_connect_to_another_one() {

        let findMeSomeNodeRequest = FindMeSomeNodeRequest(shards: .init(single: 1))

        let slowNode = node1
        let fastNode = node2
        print("slow node: \(slowNode)")
        print("🚀 fast node: \(fastNode)")
        
        let waitForConnectionDurationInSeconds: TimeInterval = 0.1
        
        let findANodeEpic = FindANodeEpic(
            determineIfPeerIsSuitable: .allPeersAreSuitable,
            radixPeerSelector: .prefer(order: [slowNode, fastNode]),
            determineIfMoreInfoAboutNodeIsNeeded: .neverAskForMoreInfo,
            determineIfNodeIsTooSlowToConnect: .tooSlowIfEqual(to: slowNode),
            waitForConnectionDurationInSeconds: waitForConnectionDurationInSeconds
        )

        let networkState: RadixNetworkState = [
            RadixNodeState(node: slowNode, webSocketStatus: .disconnected),
            RadixNodeState(node: fastNode, webSocketStatus: .disconnected)
        ]

        var returnValues = [NodeAction]()
        let expectation = XCTestExpectation(description: self.debugDescription)

        let actionsSubject = PassthroughSubject<NodeAction, Never>()
        let networkStateSubject = PassthroughSubject<RadixNetworkState, Never>()

        let cancellable = findANodeEpic.epic(
            actions: actionsSubject.eraseToAnyPublisher(),
            networkState: networkStateSubject.eraseToAnyPublisher()
        )
            .receive(on: RunLoop.main)
        .handleEvents(
            receiveOutput: { outputtedNodeAction in
                print("🤷‍♂️ handling output: \(outputtedNodeAction)")
                guard outputtedNodeAction is ConnectWebSocketAction else { return }
                print("🤷‍♂️🔗 handling ConnectWebSocketAction: \(outputtedNodeAction)")
                if outputtedNodeAction.node == slowNode {
                    networkStateSubject.send(
                        [
                            RadixNodeState(node: slowNode, webSocketStatus: .connecting),
                            RadixNodeState(node: fastNode, webSocketStatus: .disconnected)
                        ]
                    )
                } else {
                    networkStateSubject.send(
                        [
                            RadixNodeState(node: slowNode, webSocketStatus: .connecting),
                            RadixNodeState(node: fastNode, webSocketStatus: .connected)
                        ]
                    )
                }
            }
        )
            .prefix(4)
        .sink(
            receiveCompletion: { print("🥅 EXPECTATION FULFIL, completion: \($0)"); expectation.fulfill() },
            receiveValue: { print("✅ outputted: \($0)"); returnValues.append($0) }
        )
        
        networkStateSubject.send(networkState)
        actionsSubject.send(findMeSomeNodeRequest)
        
        
        wait(for: [expectation], timeout: 5*waitForConnectionDurationInSeconds)
        
        XCTAssertEqual(returnValues.count, 4, "Expected 4 actions, but got: `\(returnValues.count)`, specifically: `\(returnValues)`")
        
        let action0 = returnValues[0]
        XCTAssertType(of: action0, is: ConnectWebSocketAction.self)
        XCTAssertEqual(action0.node, slowNode)
        
        let action1 = returnValues[1]
        XCTAssertType(of: action1, is: ConnectWebSocketAction.self)
        XCTAssertEqual(action1.node, fastNode)
        
        let action2 = returnValues[2]
        XCTAssertType(of: action2, is: FindANodeResultAction.self)
        XCTAssertEqual(action2.node, fastNode)
        
        let action3 = returnValues[3]
        XCTAssertType(of: action3, is: CloseWebSocketAction.self)
        XCTAssertEqual(action3.node, slowNode)
        
        XCTAssertNotNil(cancellable)
    }
}

// MARK: Helpers
struct FindMeSomeNodeRequest: FindANodeRequestAction {
    let shards: Shards
}

public extension DetermineIfPeerIsSuitable {
    static var allPeersAreSuitable: DetermineIfPeerIsSuitable { return Self { _, _ in true } }
    static var allPeersAreUnsuitable: DetermineIfPeerIsSuitable { return Self { _, _ in false } }
}



public extension DetermineIfPeerIsSuitable {
    static var ifShardSpaceIsKnownDisregardingItsValue: DetermineIfPeerIsSuitable {
        return Self { nodeState, _ in nodeState.shardSpace != nil }
    }
}

public extension DetermineIfNodeIsTooSlowToConnect {
//    static var alwaysConsideredTooSlow: DetermineIfNodeIsTooSlowToConnect {
//        return Self { _ in true }
//    }
    
    static func tooSlowIfEqual(to tooSlowNode: Node) -> DetermineIfNodeIsTooSlowToConnect {
        return Self { connectionAction, _ in connectionAction.node == tooSlowNode }
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

extension Shards {
    static var irrelevant: Self { .init(single: .irrelevant) }
}

var nextNode: UInt8 = 1
func makeNode() -> Node {
    defer { nextNode += 1 }
    return try! Node(domain: "1.1.1.\(nextNode)", port: 1, isUsingSSL: false)
}

extension DetermineIfMoreInfoAboutNodeIsNeeded {
    static var neverAskForMoreInfo: DetermineIfMoreInfoAboutNodeIsNeeded {
        return Self { _ in false }
    }
    
}

public extension RadixPeerSelector {
    
    static var last: RadixPeerSelector {
        .init { $0.last }
    }
}
