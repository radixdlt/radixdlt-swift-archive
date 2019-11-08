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

class NetworkEpicTestCase: TestCase {
    
    let node1 = makeNode()
    let node2 = makeNode()
    
    func doTest<Epic>(
        epic: Epic,
        
        line: UInt = #line,
        
        timeout: TimeInterval = 0.5,
        
        expectedNumberOfOutput: Int,
        
        input: (
        _ nodeActionsSubject: PassthroughSubject<NodeAction, Never>,
        _ networkStateSubject: PassthroughSubject<RadixNetworkState, Never>
        ) -> Void,
        
        outputtedNodeActionsHandler: ([NodeAction]) -> Void
    ) where Epic: RadixNetworkEpic {
        
        doTest(
            epic: epic,
            line: line,
            timeout: timeout,
            resultingPublisherTransformation: { _, _, output in output.prefix(expectedNumberOfOutput)^ },
            input: input,
            outputtedNodeActionsHandler: outputtedNodeActionsHandler
        )
        
    }
    
    func doTest<Epic>(
        epic: Epic,
        
        line: UInt = #line,
        
        timeout: TimeInterval = 0.5,
        
        resultingPublisherTransformation: (
        _ inputNodeActionSubject: PassthroughSubject<NodeAction, Never>,
        _ inputNetworkStateSubject: PassthroughSubject<RadixNetworkState, Never>,
        _ outputNodeActionPublisher: AnyPublisher<NodeAction, Never>
        ) -> AnyPublisher<NodeAction, Never> = { _, _, output in output },
        
        input: (
        _ nodeActionsSubject: PassthroughSubject<NodeAction, Never>,
        _ networkStateSubject: PassthroughSubject<RadixNetworkState, Never>
        ) -> Void,
        
        outputtedNodeActionsHandler: ([NodeAction]) -> Void
    ) where Epic: RadixNetworkEpic {
        
        let actionsSubject = PassthroughSubject<NodeAction, Never>()
        let networkStateSubject = PassthroughSubject<RadixNetworkState, Never>()
        
        let expectation = XCTestExpectation(description: self.debugDescription)
        var receivedValues = [NodeAction]()
        
        let resultingPublisher = resultingPublisherTransformation(
            actionsSubject, networkStateSubject,
            epic.handle(
                actions: actionsSubject^,
                networkState: networkStateSubject^
            )
        )
        
        let cancellable = resultingPublisher.sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { receivedValues.append($0) }
        )
        
        input(actionsSubject, networkStateSubject)
        
        wait(for: [expectation], timeout: timeout)
        
        outputtedNodeActionsHandler(receivedValues)
        
        XCTAssertNotNil(cancellable, line: line)
    }
    
}
