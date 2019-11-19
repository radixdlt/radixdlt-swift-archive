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

public final class FetchAtomsEpic: RadixNetworkWebSocketsEpic {
    
    // MARK: Injected properties
    private let webSocketConnector: WebSocketConnector
    private let webSocketCloser: WebSocketCloser
    
    private let makeAtomsObserver: (FullDuplexCommunicationChannel) -> AtomsByAddressSubscribing
    private let makeAtomsObservationCanceller: (FullDuplexCommunicationChannel) -> AtomSubscriptionCancelling
    
    // MARK: Non-injected
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        webSocketConnector: WebSocketConnector,
        webSocketCloser: WebSocketCloser,
        makeAtomsObserver: @escaping (FullDuplexCommunicationChannel) -> AtomsByAddressSubscribing = DefaultRPCClient.init,
        makeAtomsObservationCanceller: @escaping (FullDuplexCommunicationChannel) -> AtomSubscriptionCancelling = DefaultRPCClient.init
    ) {
        self.webSocketConnector = webSocketConnector
        self.webSocketCloser = webSocketCloser
        self.makeAtomsObserver = makeAtomsObserver
        self.makeAtomsObservationCanceller = makeAtomsObservationCanceller
    }
}

public extension FetchAtomsEpic {
    convenience init(webSockets webSocketsManager: WebSocketsManager) {
        self.init(
            webSocketConnector: .byWebSockets(manager: webSocketsManager),
            webSocketCloser: .byWebSockets(manager: webSocketsManager)
        )
    }
}

// MARK: RadixNetworkEpic
public extension FetchAtomsEpic {
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        let fetch = nodeActionPublisher
            .compactMap(typeAs: FindANodeResultAction.self)
            .filter { $0.request is FetchAtomsActionRequest }
            .flatMap { [weak self] (nodeFound: FindANodeResultAction) -> AnyPublisher<NodeAction, Never> in
                guard let selfNonWeak = self else {
                    return Empty<NodeAction, Never>.init(completeImmediately: true).eraseToAnyPublisher()
                }
                let node = nodeFound.node
                let fetchAtomsActionRequest = castOrKill(instance: nodeFound.request, toType: FetchAtomsActionRequest.self)
                
                return selfNonWeak.webSocketConnector.newClosedWebSocketConnectionToNode(node)
                    .connectAndNotifyWhenConnected()
                    .flatMap { webSocketToNode in
                        selfNonWeak.fetchAtoms(
                            from: webSocketToNode,
                            request: fetchAtomsActionRequest
                        )
                    }^
            }
        
        let cancelFetch = nodeActionPublisher
            .compactMap(typeAs: FetchAtomsActionCancel.self)
            .ignoreOutput(mapToType: NodeAction.self)
        
        return cancelFetch.merge(with: fetch)^
        
    }
}

// MARK: - Private
private extension FetchAtomsEpic {
    
    func fetchAtoms(
        from webSocketToNode: WebSocketToNode,
        request: FetchAtomsActionRequest
    ) -> AnyPublisher<NodeAction, Never> {

        let rpcAtomsObserver = makeAtomsObserver(webSocketToNode)
        let rpcAtomsObservingCanceller = makeAtomsObservationCanceller(webSocketToNode)

        let node = webSocketToNode.node
        let uuid = request.uuid
        let subscriberIdFromUuid = SubscriberId(uuid: uuid)
        let address = request.address
        
        let atomsObservation = rpcAtomsObserver.observeAtoms(subscriberId: subscriberIdFromUuid)
            .map { observation in
                FetchAtomsActionObservation(address: address, node: node, atomObservation: observation, uuid: uuid)
            }
            .map { $0 as NodeAction }^

        func cleanUp() {
            rpcAtomsObservingCanceller.cancelAtomsSubscription(subscriberId: subscriberIdFromUuid)
                .ignoreOutput()
                .sink { [weak self] in
                    self?.webSocketCloser.closeWebSocketToNode(node)
                }
                .store(in: &cancellables)
        }
        
        return
            rpcAtomsObserver.sendAtomsSubscribe(to: address, subscriberId: subscriberIdFromUuid)
                .ignoreOutput(mapToType: NodeAction.self)
                .append(atomsObservation)
                .handleEvents(receiveCompletion: { _ in cleanUp() }, receiveCancel: { cleanUp() })
                .eraseToAnyPublisher()
    }
}

