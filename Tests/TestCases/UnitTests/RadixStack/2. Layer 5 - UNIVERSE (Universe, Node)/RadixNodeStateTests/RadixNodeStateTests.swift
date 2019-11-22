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

private let host = try! Host(domain: "8.8.8.8", port: 1)
private let node = try! Node(host: host, isUsingSSL: true)

private let nodeInfo = NodeInfo(
    system: try! RadixSystem(lower: 1, upperInclusive: 9),
    host: host
)

class RadixNodeStateTests: TestCase {

    func testThatHostOfNodeEqualsHostOfNodeInfo() throws {
        let state = try RadixNodeState(node: node, webSocketStatus: .connected, nodeInfo: nodeInfo)
        XCTAssertEqual(state.nodeInfo?.host, state.node.host)
    }

    func testSameNodeSameWebSocketStatusSameUniverseConfigSameNodeInfoEqual() throws {
        XCTAssertEqual(
            try nodeState(webSocketStatus: .connected),
            try nodeState(webSocketStatus: .connected)
        )
    }

    func testSameNodeDifferemtWebSocketStatusSameUniverseConfigSameNodeInfoNotEqual() throws {
        XCTAssertNotEqual(
            try nodeState(webSocketStatus: .connected),
            try nodeState(webSocketStatus: .connecting)
        )
    }
    
    func testSameNodeSameWebSocketStatusSameUniverseConfigDifferentNodeInfoNotEqual() throws {
        let nodeInfo2 = NodeInfo(
            system: try! RadixSystem(lower: 5, upperInclusive: 15),
            host: host
        )

        XCTAssertNotEqual(
            try nodeState(webSocketStatus: .connected, nodeInfo: nodeInfo),
            try nodeState(webSocketStatus: .connected, nodeInfo: nodeInfo2)
        )
    }
    
    func testSameNodeSameWebSocketStatusDifferentUniverseConfigSameNodeInfoNotEqual() throws {
        XCTAssertNotEqual(
            try nodeState(webSocketStatus: .connected, universeConfig: .localnet),
            try nodeState(webSocketStatus: .connected, universeConfig: nil)
        )
    }
    
    func testDifferentNodeSameWebSocketStatusSameUniverseConfigSameNodeInfoEqual() throws {
        let node2 = try! Node(host: host, isUsingSSL: false)
        XCTAssertNotEqual(node, node2)
        
        XCTAssertNotEqual(
            try nodeState(webSocketStatus: .connected, node: node),
            try nodeState(webSocketStatus: .connected, node: node2)
        )
    }
    
    func testAssertErrorIsThrownWhenHostOfNodeInfoAndHostOfNodeDiffers() {
        let host2 = try! Host(domain: "4.4.4.4", port: 237)
        XCTAssertNotEqual(host, host2)
        let nodeInfo2 = NodeInfo(
            system: try! RadixSystem(lower: 5, upperInclusive: 15),
            host: host2
        )
        XCTAssertNotEqual(node.host, nodeInfo2.host)

        
        XCTAssertThrowsSpecificError(
            try RadixNodeState(node: node, webSocketStatus: .connected, nodeInfo: nodeInfo2),
            RadixNodeState.Error.hostOfNodeInfoDifferentThanHostOfNode(hostOfNodeInfo: host2, hostOfNode: host)
        )
    }
}

private extension RadixNodeStateTests {
    func nodeState(
        webSocketStatus: WebSocketStatus,
        node aNode: Node = node,
        nodeInfo aNodeInfo: NodeInfo? = nodeInfo,
        universeConfig: UniverseConfig? = .localnet
    ) throws -> RadixNodeState {
        try RadixNodeState(node: aNode, webSocketStatus: webSocketStatus, nodeInfo: aNodeInfo, universeConfig: universeConfig)
    }
}
