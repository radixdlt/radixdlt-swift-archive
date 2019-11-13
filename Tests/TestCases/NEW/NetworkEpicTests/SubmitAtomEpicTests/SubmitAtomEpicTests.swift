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
        let atom = SignedAtom.irrelevant
        let submitAtomActionRequest = SubmitAtomActionRequest(atom: atom, isCompletingOnStoreOnly: true)
        
        doTestSubmitAtomEpic(
            submitAtomAction: submitAtomActionRequest,
            expectedNumberOfOutput: 3,
            
            input: { node, actionsSubject, _ in
                actionsSubject.send(FindANodeResultAction(node: node, request: submitAtomActionRequest))
            },
            
            emulateRadixNetworkController: { outputtedNodeAction, nodeActionsSubject, atomStatusNotificationSubject in
                if let submitAtomActionSend = outputtedNodeAction as? SubmitAtomActionSend {
                    nodeActionsSubject.send(submitAtomActionSend)
                    atomStatusNotificationSubject.send(.stored)
                }
                
                if let submitAtomActionStatus = outputtedNodeAction as? SubmitAtomActionStatus {
                    nodeActionsSubject.send(submitAtomActionStatus)
                }
            },
            
            outputtedSubmitAtomAction: { submitAtomActions in
                XCTAssertType(of: submitAtomActions[0], is: SubmitAtomActionSend.self)
                
                guard let submitAtomActionStatus = submitAtomActions[1] as? SubmitAtomActionStatus else {
                    return XCTFail("Expected SubmitAtomActionStatus")
                }
                XCTAssertEqual(submitAtomActionStatus.statusEvent, .stored)
                
                XCTAssertType(of: submitAtomActions[2], is: SubmitAtomActionCompleted.self)
            }
        )
        
    }
    
    func test_that_atom_submission_when_specifying_origin_node_completes_when_atom_gets_stored() {
        let atom = SignedAtom.irrelevant
        let originNode: Node = node2
        let submitAtomActionSend = SubmitAtomActionSend(atom: atom, node: originNode, isCompletingOnStoreOnly: true)
        
        doTestSubmitAtomEpic(
            submitAtomAction: submitAtomActionSend,
            expectedNumberOfOutput: 2,
            node: originNode,
            
            input: { _, actionsSubject, atomStatusNotificationSubject in
                actionsSubject.send(submitAtomActionSend)
                atomStatusNotificationSubject.send(.stored)
            },
            
            outputtedSubmitAtomAction: { submitAtomActions in
                
                guard let submitAtomActionStatus = submitAtomActions[0] as? SubmitAtomActionStatus else {
                    return XCTFail("Expected SubmitAtomActionStatus")
                }
                XCTAssertEqual(submitAtomActionStatus.statusEvent, .stored)
                
                XCTAssertType(of: submitAtomActions[1], is: SubmitAtomActionCompleted.self)
            }
        )
    }
    
    func test_timeout() {
        
        let atom = SignedAtom.irrelevant
        let originNode: Node = node2
        let submitAtomActionSend = SubmitAtomActionSend(atom: atom, node: originNode, isCompletingOnStoreOnly: true)
        
        doTestSubmitAtomEpic(
            submitAtomAction: submitAtomActionSend,
            expectedNumberOfOutput: 1,
            node: originNode,
            epicSubmissionMaxDuration: 1,
            
            input: { _, actionsSubject, atomStatusNotificationSubject in
                actionsSubject.send(submitAtomActionSend)
            },
            
            outputtedSubmitAtomAction: { submitAtomActions in
                XCTAssertType(of: submitAtomActions[0], is: SubmitAtomActionCompleted.self)
                let completed = castOrKill(instance: submitAtomActions[0], toType: SubmitAtomActionCompleted.self)
                XCTAssertEqual(completed.result, .failure(.timeout))
            }
        )
    }
}

private extension SubmitAtomEpicTests {
    func doTestSubmitAtomEpic(
        submitAtomAction submitAtomActionInitial: SubmitAtomAction,
        expectedNumberOfOutput: Int,
        node specifiedNode: Node? = nil,
        epicSubmissionMaxDuration: Int? = nil,
        
        line: UInt = #line,
        
        input: @escaping (
        _ node: Node,
        _ nodeActionsSubject: PassthroughSubject<NodeAction, Never>,
         _ atomStatusNotificationSubject: PassthroughSubject<AtomStatusEvent, Never>
        ) -> Void,
        
        emulateRadixNetworkController: ((
        _ reactingToOutputtedNodeAction: NodeAction,
        _ nodeActionsSubject: PassthroughSubject<NodeAction, Never>,
        _ atomStatusNotificationSubject: PassthroughSubject<AtomStatusEvent, Never>
        ) -> Void)? = nil,
        
        outputtedSubmitAtomAction: ([SubmitAtomAction]) -> Void
        
    ) {
        
        let node: Node = specifiedNode ?? node1
        
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
            makeAtomStatusObservationCanceller: { _ in atomStatusObservationCanceller },
            submissionTimeoutInSeconds: epicSubmissionMaxDuration
        )
        
        XCTAssertEqual(atomStatusObservationRequesting.sendGetAtomStatusNotifications_method_call_count, 0, line: line)
        XCTAssertEqual(atomStatusObservationCanceller.closeAtomStatusNotifications_method_call_count, 0, line: line)
        XCTAssertEqual(atomStatusObserving.observeAtomStatusNotifications_method_call_count, 0, line: line)
        XCTAssertEqual(atomSubmitter.pushAtom_method_call_count, 0, line: line)
        
        XCTAssertNil(retainSocket, line: line)
        XCTAssertNil(nodeForWhichWebSocketConnectionWasClosed, line: line)
        
        let overridingTimeoutIfPresent: TimeInterval? = epicSubmissionMaxDuration.map { TimeInterval.init($0 * 2) } ?? nil
        
        if let epicSubmissionMaxDuration = epicSubmissionMaxDuration {
            XCTAssertEqual(overridingTimeoutIfPresent!, TimeInterval(2*epicSubmissionMaxDuration))
        }
        
        doTest(
            epic: epic,
            timeout: overridingTimeoutIfPresent,
            resultingPublisherTransformation: { actionSubject, _, output in
                output
                    .receive(on: RunLoop.main)
                    .handleEvents(
                        receiveOutput: {
                            emulateRadixNetworkController?($0, actionSubject, atomStatusNotificationSubject)
                    }
                )
                    .prefix(expectedNumberOfOutput)^
        },
            input: { actionSubject, _ in input(node, actionSubject, atomStatusNotificationSubject) },
            
            outputtedNodeActionsHandler: { producedActions in
                let submitAtomActions = producedActions.compactMap { $0 as? SubmitAtomAction }
                XCTAssertEqual(submitAtomActions.count, expectedNumberOfOutput, line: line)
                
                let atom = submitAtomActionInitial.atom.wrappedAtom.wrappedAtom
                
                for submitAtomAction in submitAtomActions {
                    XCTAssertEqual(submitAtomAction.atom.wrappedAtom.wrappedAtom, atom, line: line)
                    XCTAssertEqual(submitAtomAction.node, node, line: line)
                    XCTAssertEqual(submitAtomAction.uuid, submitAtomActionInitial.uuid, line: line)
                }
                
                outputtedSubmitAtomAction(submitAtomActions)
                
                // Assure correctness of "inner" functions/publishers
                XCTAssertEqual(atomStatusObservationCanceller.closeAtomStatusNotifications_method_call_count, 1, line: line)
                XCTAssertEqual(atomStatusObserving.observeAtomStatusNotifications_method_call_count, 1, line: line)
                XCTAssertEqual(atomStatusObservationRequesting.sendGetAtomStatusNotifications_method_call_count, 1, line: line)
                XCTAssertEqual(atomSubmitter.pushAtom_method_call_count, 1, line: line)
                
                do {
                    let webSocketToNode = try XCTUnwrap(retainSocket)
                    XCTAssertEqual(webSocketToNode.node, node, line: line)
                    
                    let closedWSNode = try XCTUnwrap(nodeForWhichWebSocketConnectionWasClosed)
                    XCTAssertEqual(closedWSNode, node, line: line)
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
