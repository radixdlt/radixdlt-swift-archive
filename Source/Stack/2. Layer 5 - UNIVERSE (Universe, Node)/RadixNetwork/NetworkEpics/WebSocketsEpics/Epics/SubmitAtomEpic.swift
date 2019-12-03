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
import Combine

public final class SubmitAtomEpic: RadixNetworkWebSocketsEpic {
    
    // MARK: Injected properties
    private let webSocketConnector: WebSocketConnector
    private let webSocketCloser: WebSocketCloser
    
    private let makeAtomStatusObserving: (FullDuplexCommunicationChannel) -> AtomStatusObserving
    private let makeAtomStatusObservationRequesting: (FullDuplexCommunicationChannel) -> AtomStatusObservationRequesting
    private let makeAtomSubmitting: (FullDuplexCommunicationChannel) -> AtomSubmitting
    private let makeAtomStatusObservationCanceller: (FullDuplexCommunicationChannel) -> AtomStatusObservationCancelling

    // MARK: Non-injected properties
    private var cancellables = Set<AnyCancellable>()
    
    private let submissionTimeoutInSeconds: RadixSchedulers.MainThread.SchedulerTimeType.Stride
    
    public init(
        webSocketConnector: WebSocketConnector,
        webSocketCloser: WebSocketCloser,
        
        makeAtomStatusObserving: @escaping (FullDuplexCommunicationChannel) -> AtomStatusObserving = DefaultRPCClient.init,
       
        makeAtomStatusObservationRequesting: @escaping (FullDuplexCommunicationChannel) -> AtomStatusObservationRequesting = DefaultRPCClient.init,
       
        makeAtomSubmitting: @escaping (FullDuplexCommunicationChannel) -> AtomSubmitting = DefaultRPCClient.init,
        
        makeAtomStatusObservationCanceller: @escaping (FullDuplexCommunicationChannel) -> AtomStatusObservationCancelling = DefaultRPCClient.init,
        
        submissionTimeoutInSeconds overridingSubmissionTimeoutInSeconds: Int? = nil
    ) {
        self.webSocketConnector = webSocketConnector
        self.webSocketCloser = webSocketCloser
        self.makeAtomStatusObserving = makeAtomStatusObserving
        self.makeAtomStatusObservationRequesting = makeAtomStatusObservationRequesting
        self.makeAtomSubmitting = makeAtomSubmitting
        self.makeAtomStatusObservationCanceller = makeAtomStatusObservationCanceller
        self.submissionTimeoutInSeconds = RadixSchedulers.MainThread.SchedulerTimeType.Stride.seconds(overridingSubmissionTimeoutInSeconds ?? Self.defaultSubmissionTimeoutInSeconds)
    }
}

public extension SubmitAtomEpic {
    
    static let defaultSubmissionTimeoutInSeconds: Int = 30
    
    convenience init(webSockets webSocketsManager: WebSocketsManager) {
        self.init(
            webSocketConnector: .byWebSockets(manager: webSocketsManager),
            webSocketCloser: .byWebSockets(manager: webSocketsManager)
        )
    }
    
}

public extension SubmitAtomEpic {
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState _: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        let foundNode = nodeActionPublisher
            .compactMap(typeAs: FindANodeResultAction.self)
            .filter { $0.request is SubmitAtomActionRequest }^
            .map { findANodeResultAction -> NodeAction in
                let request = castOrKill(instance: findANodeResultAction.request, toType: SubmitAtomActionRequest.self)
                return SubmitAtomActionSend(request: request, node: findANodeResultAction.node) as NodeAction
            }^

        let submitToNode = nodeActionPublisher
            .compactMap(typeAs: SubmitAtomActionSend.self)
            .flatMap { [weak self] submitAtomAction ->  AnyPublisher<NodeAction, Never> in
                guard let selfNonWeak = self else {
                    return Empty<NodeAction, Never>.init(completeImmediately: true).eraseToAnyPublisher()
                }
                let node = submitAtomAction.node
                return selfNonWeak.webSocketConnector.newClosedWebSocketConnectionToNode(node)
                    .connectAndNotifyWhenConnected()
                    .andThen(
                        selfNonWeak.submitAtom(sendAction: submitAtomAction, toNode: node)
                )
            }^
        
        return foundNode.merge(with: submitToNode).eraseToAnyPublisher()
    }
}

private extension SubmitAtomEpic {
    
    // swiftlint:disable function_body_length
    
    func submitAtom(sendAction: SubmitAtomActionSend, toNode node: Node) -> AnyPublisher<NodeAction, Never> {
        // swiftlint:enable function_body_length
        let webSocketToNode = webSocketConnector.newClosedWebSocketConnectionToNode(node)
        
        let atomStatusObserver = makeAtomStatusObserving(webSocketToNode)
        let atomStatusSubscriber = makeAtomStatusObservationRequesting(webSocketToNode)
        let atomSubmitter = makeAtomSubmitting(webSocketToNode)
        let atomStatusSubscriptionCanceller = makeAtomStatusObservationCanceller(webSocketToNode)
        
        let submitAtomActionSubject = PassthroughSubject<SubmitAtomAction, Never>()
        let subscriberId = SubscriberId(uuid: UUID())
        let atom = sendAction.atom

        func cleanUp() {
            atomStatusSubscriptionCanceller
                .closeAtomStatusNotifications(subscriberId: subscriberId)
                .ignoreOutput()
                .sink { [weak self] in
                    self?.webSocketCloser.closeWebSocketToNode(node)
            }
            .store(in: &cancellables)
        }
        
        return atomStatusObserver
            .observeAtomStatusNotifications(subscriberId: subscriberId)
            .flatMap { statusEvent -> AnyPublisher<NodeAction, Never> in
                let statusAction = SubmitAtomActionStatus(sendAction: sendAction, node: node, statusEvent: statusEvent)
                if statusEvent == .stored || !sendAction.completeOnAtomStoredOnly {
                    return Publishers.Sequence<[NodeAction], Never>(sequence: [
                        statusAction,
                        SubmitAtomActionCompleted.success(sendAction: sendAction, node: node)
                        ]
                    ).eraseToAnyPublisher()
                } else {
                    return Just(statusAction)^
                }
            }^
            .handleEvents(
                receiveSubscription: { _ in
                    atomStatusSubscriber
                        .sendGetAtomStatusNotifications(atomIdentifier: atom.identifier(), subscriberId: subscriberId)
                        .ignoreOutput()
                        .andThen(
                            atomSubmitter.pushAtom(atom)
                                .flatMap { _ in Empty<NodeAction, SubmitAtomError>(completeImmediately: true)^ }^
                                .catch { submitAtomError -> Empty<NodeAction, Never> in
                                    submitAtomActionSubject.send(
                                        SubmitAtomActionStatus(
                                            sendAction: sendAction,
                                            node: node,
                                            statusEvent: .notStored(
                                                reason: AtomNotStoredReason(.evictedInvalidAtom, error: submitAtomError)
                                            )
                                        )
                                    )
                                    
                                    submitAtomActionSubject.send(
                                        SubmitAtomActionCompleted.success(sendAction: sendAction, node: node)
                                    )
                                    return Empty<NodeAction, Never>(completeImmediately: true)
                                }
                        )
                        .sink(
                            receiveFinish: {
                                submitAtomActionSubject.send(
                                    SubmitAtomActionReceived(sendAction: sendAction, node: node)
                                )
                            }
                        )
                        .store(in: &self.cancellables)
                },
                receiveCompletion: { _ in cleanUp() },
                receiveCancel: { cleanUp() }
            )^
            
            // Important: this makes sure that the publisher returned by
            // `observeAtomStatusNotifications` does not result in two subscriptions,
            // but one shared. Without this `sendGetAtomStatusNotifications` and
            // thus `pushAtom` gets called twice. There might be some better
            // solution to this, but for now it works.
            .share()
            
            .merge(with: submitAtomActionSubject.map { $0 as NodeAction })^
            .setFailureType(to: Publishers.TimeoutError.self)
            .timeout(submissionTimeoutInSeconds, scheduler: RadixSchedulers.mainThreadScheduler) { Publishers.TimeoutError.publisherTimeout }
            .replaceError(with: SubmitAtomActionCompleted.failed(sendAction: sendAction, node: node, error: .timeout))
            .eraseToAnyPublisher()
            .prefixWhile { $0 is SubmitAtomActionCompleted == false }
        
    }
    
}

public extension Publishers {
    enum TimeoutError: Int, Swift.Error, Equatable {
        case publisherTimeout
    }
}
