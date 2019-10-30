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

class FindANodeEpicTests: FindANodeEpicTestCases {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_that_we_can_create_an_epic() {
        XCTAssertNotNil(FindANodeEpic())
    }
    
    func test_valid_client() {
        
        
        let findMeSomeNodeRequest = FindMeSomeNodeRequest(shards: .init(single: 1))
        
        let findANodeEpic = FindANodeEpic(
            radixPeerSelector: .first,
            determineIfPeerIsSuitable: .allPeersAreSuitable
        )
        
        let networkState: RadixNetworkState = [RadixNodeState(node: node1, webSocketStatus: .connected)]
        
        var returnValues = [NodeAction]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let actionsSubject = PassthroughSubject<NodeAction, Never>()
        
        let cancellable = findANodeEpic.epic(
            actions: actionsSubject.eraseToAnyPublisher(),
            networkState: Just(networkState).eraseToAnyPublisher()
        ).sink(
            receiveCompletion: { completion in
                print("⭐️ completion: \(completion)")
                expectation.fulfill()
                
        },
            receiveValue: { nodeAction in
                print("🎉 nodeAction: \(nodeAction)")
                returnValues.append(nodeAction)
            }
        )
        
        actionsSubject.send(findMeSomeNodeRequest)
        actionsSubject.send(completion: .finished)
        
        wait(for: [expectation], timeout: 0.01)
        
        XCTAssertEqual(returnValues.count, 1)
        XCTAssertTrue(returnValues[0] is FindANodeResultAction, "Expected type `FindANodeResultAction`, but got: \(type(of: returnValues[0]))")
        XCTAssertEqual(returnValues[0].node, node1)
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
