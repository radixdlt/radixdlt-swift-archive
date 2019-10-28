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
import EntwineTest

struct FindMeSomeNodeRequest: FindANodeRequestAction {
    let shards: Shards
}

public extension ShardsMatcher {
    static var alwaysMatch: Self { ShardsMatcher { _, _ in true } }
}

public extension NodeCompatibilityChecker {
    static var allNodesAreSuitable: NodeCompatibilityChecker {
        Self { _, _ in true }
    }
}

class FindANodeEpicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_that_we_can_create_an_epic() {
        XCTAssertNotNil(FindANodeEpic())
    }
    
    func test_valid_client() {
        
        let testScheduler = TestScheduler(initialClock: 0)
        
        let node = try! Node(domain: "1.1.1.1", port: 1, isUsingSSL: false)
//        let webSocketClient = WebSocketToNode(node: node, shouldConnect: false)
        
        let findMeSomeNodeRequest = FindMeSomeNodeRequest(shards: .init(single: 1))
        
        let findANodeEpic = FindANodeEpic(
            radixPeerSelector: .first,
            shardsMatcher: .alwaysMatch,
            nodeCompatibilityChecker: .allNodesAreSuitable
        )
        
        let networkState: RadixNetworkState = [RadixNodeState(node: node, webSocketStatus: .ready)]
        
        var returnValues = [NodeAction]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
//        let nodeActionSubject = PassthroughSubject<NodeAction, Never>()
        
        let cancellable = findANodeEpic.epic(
//            actions: nodeActionSubject.eraseToAnyPublisher(),
            actions: Just(findMeSomeNodeRequest).eraseToAnyPublisher(),
            networkState: Just(networkState).eraseToAnyPublisher()
        ).sink(
            receiveCompletion: {
                completion in
                print("☢️ completion: \(completion)")
                expectation.fulfill()
                
        },
            receiveValue: { nodeAction in
                
                print("🔮 NodeAction: \(nodeAction)")
                returnValues.append(nodeAction)
                
            }
        )
        
//        nodeActionSubject.send(findMeSomeNodeRequest)
        
        wait(for: [expectation], timeout: 0.5)
        
        
        XCTAssertEqual(returnValues.count, 1)
        XCTAssertTrue(returnValues[0] is FindANodeResultAction)
        XCTAssertEqual(returnValues[0].node, node)
        XCTAssertNotNil(cancellable)
    }
    
    func test_filterActionsRequiringNode() {
        
        let epic = FindANodeEpic()
        var returnValues = [NodeAction]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let nodeSubject = PassthroughSubject<NodeAction, Never>()
        
        let function = epic.filterActionsRequiringNode
        
        let publisher = function(nodeSubject.eraseToAnyPublisher())
        
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                expectation.fulfill()
        },
            receiveValue: { nodeAction in returnValues.append(nodeAction) })
            
        
        nodeSubject.send(DiscoverMoreNodesAction())
        nodeSubject.send(FetchAtomsActionRequest(address: .irrelevant))
        nodeSubject.send(AddNodeAction(node: .mocked))
        nodeSubject.send(FetchAtomsActionRequest(address: .irrelevant))
        nodeSubject.send(ConnectWebSocketAction(node: .mocked))
        
        
        nodeSubject.send(completion: .finished)
        
        wait(for: [expectation], timeout: 0.01)
        
        XCTAssertEqual(returnValues.count, 2)
        XCTAssertTrue(returnValues.allSatisfy { $0 is FetchAtomsActionRequest})
        
        XCTAssertNotNil(cancellable)
    }
}

extension Node {
    static var mocked: Node { try! .init(host: .local(), isUsingSSL: false) }
}
