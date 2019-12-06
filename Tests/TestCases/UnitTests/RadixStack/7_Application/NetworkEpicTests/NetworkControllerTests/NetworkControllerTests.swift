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

class NetworkControllerTests: TestCase {

 
    func testInitialNetwork() throws {
        let node1 = makeNode(index: 1)
        let node2 = makeNode(index: 2)
        let networkState: RadixNetworkState = [
            RadixNodeState.of(node: node1, webSocketStatus: .disconnected),
            RadixNodeState.of(node: node2, webSocketStatus: .connected)
        ]
  
        XCTAssertEqual(
            try DefaultRadixNetworkController(network: DefaultRadixNetwork(state: networkState), epics: [], nodeActionReducers: []).currentNetworkState,
            networkState
        )

    }
    
    func testRadixUniverseInitialNetworkUsingBootStrapConfigLocalHostTwoNodes() {
        let universe = DefaultRadixUniverse(bootstrapConfig: UniverseBootstrap.localhostTwoNodes)
        
        let node1 = Node.localhost(port: 8080)
        let node2 = Node.localhost(port: 8081)
        
        let expectedInitialNetworkState: RadixNetworkState = [
            RadixNodeState.of(node: node1, webSocketStatus: .disconnected),
            RadixNodeState.of(node: node2, webSocketStatus: .disconnected)
        ]
        
        XCTAssertEqual(
            universe.networkController.currentNetworkState,
            expectedInitialNetworkState
        )
    }
    
    func testRadixUniverseInitialNetworkUsingBootStrapConfigLocalHostSingleNode() {
        let universe = DefaultRadixUniverse(bootstrapConfig: UniverseBootstrap.localhostSingleNode)
        
        let node1 = Node.localhost(port: 8080)
        
        let expectedInitialNetworkState: RadixNetworkState = [
            RadixNodeState.of(node: node1, webSocketStatus: .disconnected)
        ]
        
        XCTAssertEqual(
            universe.networkController.currentNetworkState,
            expectedInitialNetworkState
        )
    }
    
    func testAssertDiscoveryModeOfUniverseBootstrapLocalhostSingleNode() {
        let node1 = Node.localhost(port: 8080)
        
        let discoverMode = UniverseBootstrap.localhostSingleNode.discoveryMode
        switch discoverMode {
        case .byDiscoveryEpics:
            XCTFail("Expected discoverMode to be equal to 'byInitialNetworkOfNodes'")
        case .byInitialNetworkOfNodes(let nodes):
            XCTAssertEqual(nodes.count, 1)
            XCTAssertEqual(nodes.first, node1)
        }
    }
    
    func testAssertDiscoveryModeOfUniverseBootstrapLocalhostTwoNodes() {
        let node1 = Node.localhost(port: 8080)
        let node2 = Node.localhost(port: 8081)
        
        let discoverMode = UniverseBootstrap.localhostTwoNodes.discoveryMode
        switch discoverMode {
        case .byDiscoveryEpics:
            XCTFail("Expected discoverMode to be equal to 'byInitialNetworkOfNodes'")
        case .byInitialNetworkOfNodes(let nodes):
            XCTAssertEqual(nodes.count, 2)
            XCTAssertEqual(nodes.first, node1)
            XCTAssertEqual(nodes.last, node2)
        }
    }
    
    func testDiscoveryNetworkEpicIsEmptyForDiscoveryModeInitialNetwork() {
        let node1 = Node.localhost(port: 8080)
        let node2 = Node.localhost(port: 8081)
        
        func assertNetworkEpicsListIsEmpty(nodes: [Node]) {
            let seedNodes = OrderedSet<Node>(array: nodes)
            let mode: DiscoveryMode = .byInitialNetworkOfNodes(seedNodes)
            XCTAssertTrue(mode.radixNetworkEpics.isEmpty)
        }
        
        assertNetworkEpicsListIsEmpty(nodes: [])
        assertNetworkEpicsListIsEmpty(nodes: [node1])
        assertNetworkEpicsListIsEmpty(nodes: [node1, node2])
    }
    
    func testInitialNetworkOfNodesForDiscoverModeInitialNetworkContainsNodesPassedIn() {
        let node1 = Node.localhost(port: 8080)
        let node2 = Node.localhost(port: 8081)
        
        func assertNodes(nodes: [Node]) {
            let seedNodes = OrderedSet<Node>(array: nodes)
            let mode: DiscoveryMode = .byInitialNetworkOfNodes(seedNodes)
            XCTAssertEqual(mode.initialNetworkOfNodes.contents, nodes)
        }
        
        assertNodes(nodes: [])
        assertNodes(nodes: [node1])
        assertNodes(nodes: [node1, node2])
    }
    
    func testDiscoveryModeByEpic() {
        let node1 = Node.localhost(port: 8080)
        let epics = DiscoveryMode.byDiscovery(config: .localnet, seedNodes: Just(node1).eraseToAnyPublisher()).radixNetworkEpics
        XCTAssertEqual(epics.count, 1)
        XCTAssertType(of: epics[0], is: DiscoverNodesEpic.self)
    }
    
    func testUniverseMakeNetworkEpics() {
        let epics = DefaultRadixUniverse.makeNetworkEpics(determineIfPeerIsSuitable: .allPeersAreSuitable)
        XCTAssertEqual(epics.count, 2)
        XCTAssertType(of: epics[1], is: FindANodeEpic.self)
        let webSocketsEpic: WebSocketsEpic! = XCTAssertType(of: epics[0])
        
        XCTAssertEqual(webSocketsEpic.epics.count, 9)
    }
    
    func testUniverseMakeNetworkEpicsWithDiscovery() {
        let node1 = Node.localhost(port: 8080)
        let epics = DefaultRadixUniverse.makeNetworkEpics(
            discoveryMode: .byDiscovery(config: .localnet, seedNodes: Just(node1).eraseToAnyPublisher()),
            determineIfPeerIsSuitable: .allPeersAreSuitable
        )
        XCTAssertEqual(epics.count, 3)
        XCTAssertType(of: epics[2], is: DiscoverNodesEpic.self)
    }
    
    func testThatNetworkControllerThrowsWhenInitializedWithAnEmptyNetwork() {
        XCTAssertThrowsSpecificError(
            try DefaultRadixNetworkController(network: DefaultRadixNetwork(), epics: [], nodeActionReducers: []),
            DefaultRadixNetworkController.Error.initialNetworkStateMustContainAtLeastOneNode
        )
    }
}
