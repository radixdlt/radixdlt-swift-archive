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


class FetchAtomsEpicTests: NetworkEpicTestCase {
    
    
    func test_that_we_start_observing_atoms_given_a_FindANodeResultAction() {
        
        let node = node1
        let address: Address = .irrelevant
        
        
        let webSocketStatusSubject = CurrentValueSubject<WebSocketStatus, Never>(.disconnected)
        let observeAtomsSubject = PassthroughSubject<AtomObservation, Never>()
        let atomsObserver = AtomsSubscriber(observeAtomsSubject: observeAtomsSubject)
        let atomsObservingCanceller = AtomsCanceller()
        
        var retainSocket: WebSocketToNode?
        
        var nodeForWhichWebSocketConnectionWasClosed: Node?
        
        let epic = FetchAtomsEpic(
            webSocketConnector: .new(webSocketStatusSubject: webSocketStatusSubject, retain: { retainSocket = $0 }),
            webSocketCloser: .onClose { nodeForWhichWebSocketConnectionWasClosed = $0 },
            makeAtomsObserver: { _ in atomsObserver },
            makeAtomsObservationCanceller: { _ in atomsObservingCanceller }
        )
        
        let fetchAtomsActionRequest = FetchAtomsActionRequest(address: address)
        
        let findANodeResultAction = FindANodeResultAction(
            node: node,
            request: fetchAtomsActionRequest
        )
        
        let expectedNumberOfOutput = 1
        
        XCTAssertEqual(atomsObserver.sendAtomsSubscribe_method_call_count, 0)
        XCTAssertEqual(atomsObserver.observeAtoms_method_call_count, 0)
        XCTAssertNil(retainSocket)
        XCTAssertNil(nodeForWhichWebSocketConnectionWasClosed)
        
        doTest(
            epic: epic,
            expectedNumberOfOutput: expectedNumberOfOutput,
            input: { actionsSubject, networkStateSubject in
                actionsSubject.send(findANodeResultAction)
                webSocketStatusSubject.send(.connected)
                observeAtomsSubject.send(.headNow())
            },
            
            outputtedNodeActionsHandler: { producedOutput in
                XCTAssertEqual(producedOutput.count, expectedNumberOfOutput)
                XCTAssertEqual(atomsObserver.sendAtomsSubscribe_method_call_count, 1)
                XCTAssertEqual(atomsObserver.observeAtoms_method_call_count, 1)
                do {
                    let webSocketToNode = try XCTUnwrap(retainSocket)
                    XCTAssertEqual(webSocketToNode.node, node)

                    let closedWSNode = try XCTUnwrap(nodeForWhichWebSocketConnectionWasClosed)
                    XCTAssertEqual(closedWSNode, node)
                } catch { return XCTFail("Expected not nil") }
                
                let fetchAtomsActionObservation: FetchAtomsActionObservation! = XCTAssertType(of: producedOutput[0])
                XCTAssertEqual(fetchAtomsActionObservation.node, node)
                XCTAssertEqual(fetchAtomsActionObservation.address, address)
                XCTAssertEqual(fetchAtomsActionObservation.address, fetchAtomsActionRequest.address)
                XCTAssertEqual(fetchAtomsActionObservation.uuid, fetchAtomsActionRequest.uuid)
                
                
            }
        )
    }
}

final class AtomsSubscriber: AtomsByAddressSubscribing {
    var sendAtomsSubscribe_method_call_count = 0
    var observeAtoms_method_call_count = 0
    
    private let observeAtomsSubject: PassthroughSubject<AtomObservation, Never>
    init(observeAtomsSubject: PassthroughSubject<AtomObservation, Never>) {
        self.observeAtomsSubject = observeAtomsSubject
    }
    
    func sendAtomsSubscribe(to address: Address, subscriberId: SubscriberId) -> Completable {
        sendAtomsSubscribe_method_call_count += 1
        return  Empty<Never, Never>(completeImmediately: true).eraseToAnyPublisher()
    }
    
    func observeAtoms(subscriberId: SubscriberId) -> AnyPublisher<AtomObservation, Never> {
        observeAtoms_method_call_count += 1
        return observeAtomsSubject.eraseToAnyPublisher()
    }
    
}

final class AtomsCanceller: AtomSubscriptionCancelling {
    var cancelAtomsSubscription_method_call_count = 0
    func cancelAtomsSubscription(subscriberId: SubscriberId) -> Completable {
        cancelAtomsSubscription_method_call_count += 1
        return  Empty<Never, Never>(completeImmediately: true).eraseToAnyPublisher()
    }
}

extension WebSocketConnector {
    static func new(webSocketStatusSubject: CurrentValueSubject<WebSocketStatus, Never>, retain: @escaping (WebSocketToNode) -> Void) -> Self {
        Self { nodeToConnectTo in
            let webSocketToNode = WebSocketToNode(node: nodeToConnectTo, webSocketStatusSubject: webSocketStatusSubject)
            retain(webSocketToNode)
            return webSocketToNode
        }
    }
}

extension WebSocketCloser {
    static func onClose(_ handler: @escaping (Node) -> Void) -> Self {
        Self { nodeToClose in
            handler(nodeToClose)
        }
    }
}
