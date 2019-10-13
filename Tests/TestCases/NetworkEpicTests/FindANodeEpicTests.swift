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

class FindANodeEpicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func test_that_we_can_create_an_epic() {
        XCTAssertNotNil(FindANodeEpic())
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
