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


class SubmitAtomEpicTests: NetworkEpicTestCase {
    
    
    func test_that_atom_submission_without_specifying_originnode_completes_when_atom_gets_stored() {
        
        let node = node1
        
        let webSocketStatusSubject = CurrentValueSubject<WebSocketStatus, Never>(.connected)
        
        let atomStatusNotificationSubject = PassthroughSubject<AtomStatusEvent, Never>()
        
        let atomStatusObserving = AtomStatusObserver(subject: atomStatusNotificationSubject)
        let atomStatusObservationRequesting = AtomStatusObservationRequester()
        let atomStatusObservationCanceller = AtomStatusObservationCanceller()
        let atomSubmitter = AtomSubmitter()
        
        var retainSocket: WebSocketToNode?
        
        var nodeForWhichWebSocketConnectionWasClosed: Node?
        
        let epic = SubmitAtomEpic(
            webSocketConnector: .new(webSocketStatusSubject: webSocketStatusSubject, retain: { retainSocket = $0 }),
            webSocketCloser: .onClose { nodeForWhichWebSocketConnectionWasClosed = $0 },
            makeAtomStatusObserving: { _ in atomStatusObserving },
            makeAtomStatusObservationRequesting: { _ in atomStatusObservationRequesting },
            makeAtomSubmitting: { _ in atomSubmitter },
            makeAtomStatusObservationCanceller: { _ in atomStatusObservationCanceller }
        )
        
        // Not specifying specific origin node (which would have used `SubmitAtomActionSend`), this should trigger a `FindANodeResultAction` where `request` ==  `SubmitAtomActionRequest` flow.
        let atom = SignedAtom.irrelevant
        let submitAtomActionRequest = SubmitAtomActionRequest(atom: atom, isCompletingOnStoreOnly: true)
        let submitUUID = submitAtomActionRequest.uuid
        let findANodeResultAction = FindANodeResultAction(node: node, request: submitAtomActionRequest)
        
        let expectedNumberOfOutput = 3
        
        XCTAssertEqual(atomStatusObservationRequesting.sendGetAtomStatusNotifications_method_call_count, 0)
        XCTAssertEqual(atomStatusObservationCanceller.closeAtomStatusNotifications_method_call_count, 0)
        XCTAssertEqual(atomStatusObserving.observeAtomStatusNotifications_method_call_count, 0)
        XCTAssertEqual(atomSubmitter.pushAtom_method_call_count, 0)
        
        XCTAssertNil(retainSocket)
        XCTAssertNil(nodeForWhichWebSocketConnectionWasClosed)
        
        func emulateRadixNetworkController(
            reactingTo outputtedNodeAction: NodeAction,
            _ nodeActionsSubject: PassthroughSubject<NodeAction, Never>
        ) {
            if let submitAtomActionSend = outputtedNodeAction as? SubmitAtomActionSend {
                nodeActionsSubject.send(submitAtomActionSend)
                atomStatusNotificationSubject.send(.stored)
            }
            
            if let submitAtomActionStatus = outputtedNodeAction as? SubmitAtomActionStatus {
                nodeActionsSubject.send(submitAtomActionStatus)
                
            }
        }
        
        doTest(
            epic: epic,
            resultingPublisherTransformation: { actionSubject, _, output in
                output
                    .receive(on: RunLoop.main)
                    .handleEvents(
                    receiveOutput: {
                        emulateRadixNetworkController(reactingTo: $0, actionSubject)
                    }
                )
                    .prefix(expectedNumberOfOutput)^
        },
            input: { actionsSubject, _ in
                
                actionsSubject.send(findANodeResultAction)
            },
            
            outputtedNodeActionsHandler: { producedActions in
                let submitAtomActions = producedActions.compactMap { $0 as? SubmitAtomAction }
                XCTAssertEqual(submitAtomActions.count, expectedNumberOfOutput)
                
                for submitAtomAction in submitAtomActions {
                    XCTAssertEqual(submitAtomAction.atom.wrappedAtom.wrappedAtom, atom.wrappedAtom.wrappedAtom)
                    XCTAssertEqual(submitAtomAction.node, node)
                    XCTAssertEqual(submitAtomAction.uuid, submitUUID)
                }
                
                XCTAssertType(of: submitAtomActions[0], is: SubmitAtomActionSend.self)
                
                guard let submitAtomActionStatus = submitAtomActions[1] as? SubmitAtomActionStatus else {
                    return XCTFail("Expected SubmitAtomActionStatus")
                }
                XCTAssertEqual(submitAtomActionStatus.statusEvent, .stored)
                
                XCTAssertType(of: submitAtomActions[2], is: SubmitAtomActionCompleted.self)
                
                // Assure correctness of "inner" functions/publishers
                XCTAssertEqual(atomStatusObservationCanceller.closeAtomStatusNotifications_method_call_count, 1)
                XCTAssertEqual(atomStatusObserving.observeAtomStatusNotifications_method_call_count, 1)
                
                XCTAssertEqual(atomStatusObservationRequesting.sendGetAtomStatusNotifications_method_call_count, 1)
                XCTAssertEqual(atomSubmitter.pushAtom_method_call_count, 1)

                do {
                    let wsToNode = try XCTUnwrap(retainSocket)
                    XCTAssertEqual(wsToNode.node, node)

                    let closedWSNode = try XCTUnwrap(nodeForWhichWebSocketConnectionWasClosed)
                    XCTAssertEqual(closedWSNode, node)
                } catch { return XCTFail("Expected not nil") }
                
                
                
            }
        )
    }
}

final class AtomStatusObserver: AtomStatusObserving {
    
    var observeAtomStatusNotifications_method_call_count = 0
    let atomStatusNotificationSubject: PassthroughSubject<AtomStatusEvent, Never>
    
    init(subject atomStatusNotificationSubject: PassthroughSubject<AtomStatusEvent, Never>) {
        self.atomStatusNotificationSubject = atomStatusNotificationSubject
    }
    
    func observeAtomStatusNotifications(subscriberId: SubscriberId) -> AnyPublisher<AtomStatusEvent, Never> {
        observeAtomStatusNotifications_method_call_count += 1
        return atomStatusNotificationSubject.eraseToAnyPublisher()
    }
}

final class AtomStatusObservationRequester: AtomStatusObservationRequesting {
    
    var sendGetAtomStatusNotifications_method_call_count = 0
    
    func sendGetAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId) -> Completable {
        sendGetAtomStatusNotifications_method_call_count += 1
        return Empty<Never, Never>(completeImmediately: true).eraseToAnyPublisher()
    }
}

final class AtomSubmitter: AtomSubmitting {
    
    var pushAtom_method_call_count = 0
    
    func pushAtom(_ atom: SignedAtom) -> AnyPublisher<Never, SubmitAtomError> {
        pushAtom_method_call_count += 1
        return Empty<Never, SubmitAtomError>(completeImmediately: false).eraseToAnyPublisher()
    }
}

final class AtomStatusObservationCanceller: AtomStatusObservationCancelling {
    
    var closeAtomStatusNotifications_method_call_count = 0
    
    func closeAtomStatusNotifications(subscriberId: SubscriberId) -> Completable {
        closeAtomStatusNotifications_method_call_count += 1
        return Empty<Never, Never>(completeImmediately: true).eraseToAnyPublisher()
    }
    
}

extension SignedAtom {
    static var irrelevant: Self {
        let unsignedAtom = UnsignedAtom.irrelevant
        return unsignedAtom.signed(signature: .irrelevant, signatureId: .irrelevant)
        
    }
}

extension Signature {
    static var irrelevant: Self {
        try! Signature.init(r: 1, s: 1)
    }
}

extension UnsignedAtom {
    static var irrelevant: Self {
        try! UnsignedAtom(atomWithPow: .irrelevant)
    }
}

extension AtomWithFee {
    static var irrelevant: Self {
        try! AtomWithFee(atomWithoutPow: Atom.irrelevant, proofOfWork: .irrelevant)
    }
}

extension Atom {
    static var irrelevant: Self {
        
        let rri: ResourceIdentifier = "/\(Address.irrelevant)/\(String.irrelevant)"
        let particle = ResourceIdentifierParticle(resourceIdentifier: rri)
        let particleGroup = try! ParticleGroup(spunParticles: particle.withSpin(.up))
        
        return Atom(
            metaData: .timeNow,
            particleGroups: [particleGroup]
        )
    }
}

extension ProofOfWork {
    static var irrelevant: Self {
        Self(seed: Data(), targetNumberOfLeadingZeros: 1, magic: 1, nonce: 0)
    }
}

extension EUID {
    static var irrelevant: Self {
        try! EUID(int: 1)
    }
}
