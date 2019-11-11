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

public struct WebSocketConnector {
    public typealias NewClosedWebSocketConnectionToNode = (Node) -> WebSocketToNode
    public let newClosedWebSocketConnectionToNode: NewClosedWebSocketConnectionToNode
}

public extension WebSocketConnector {
    static func byWebSockets(manager webSocketsManager: WebSocketsManager) -> Self {
        Self { nodeToConnectTo in
            webSocketsManager.newDisconnectedWebsocket(to: nodeToConnectTo)
        }
    }
}

public struct WebSocketCloser {
    public typealias CloseWebSocketTo = (Node) -> Void
    public let closeWebSocketToNode: CloseWebSocketTo
}

public extension WebSocketCloser {
    static func byWebSockets(manager webSocketsManager: WebSocketsManager) -> Self {
        Self { nodeConnectionToClose in
            webSocketsManager.ifNoOneListensCloseAndRemoveWebsocket(toNode: nodeConnectionToClose, afterDelay: nil)
        }
    }
}

public final class FetchAtomsEpic: NetworkWebsocketEpic {
    
    public var webSockets: WebSocketsManager { fatalError("Remove property `webSockets: WebSocketsManager` from Protocol `NetworkWebsocketEpic` ") }
    private var cancellables = Set<AnyCancellable>()
//    private var cancellablesMap: [UUID: Cancellable] = [:]
    //    private let webSocketConnectionEstablisher: WebSocketConnectionEstablisher
    private let webSocketConnector: WebSocketConnector
    private let webSocketCloser: WebSocketCloser
    private let makeAtomsObserver: (FullDuplexCommunicationChannel) -> AtomsByAddressSubscribing
    private let makeAtomsObservationCanceller: (FullDuplexCommunicationChannel) -> AtomSubscriptionCancelling
    
    public init(
        //        webSockets webSocketsManager: WebSocketsManager,
        //        webSocketConnectionEstablisher: WebSocketConnectionEstablisher?
        webSocketConnector: WebSocketConnector,
        webSocketCloser: WebSocketCloser,
        makeAtomsObserver: @escaping (FullDuplexCommunicationChannel) -> AtomsByAddressSubscribing = DefaultRPCClient.init,
        makeAtomsObservationCanceller: @escaping (FullDuplexCommunicationChannel) -> AtomSubscriptionCancelling = DefaultRPCClient.init
    ) {
        //        self.webSockets = webSocketsManager
        //        self.webSocketConnectionEstablisher = webSocketConnectionEstablisher ?? WebSocketConnectionEstablisher.byWebSockets(manager: webSocketsManager)
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

public extension FetchAtomsEpic {
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        let fetch = nodeActionPublisher
            .compactMap(typeAs: FindANodeResultAction.self)
            .filter { $0.request is FetchAtomsActionRequest }
            .flatMap { [unowned self] (nodeFound: FindANodeResultAction) -> AnyPublisher<NodeAction, Never> in
                
                let node = nodeFound.node
                let fetchAtomsActionRequest = castOrKill(instance: nodeFound.request, toType: FetchAtomsActionRequest.self)
                
                //                return self.webSocketConnectionEstablisher .openWebSocketAndAwaitConnection(node)
                //                    .first().ignoreOutput()
                return self.webSocketConnector.newClosedWebSocketConnectionToNode(node)
                    .connectAndNotifyWhenConnected()
                    .flatMap { webSocketToNode in
                        self.fetchAtoms(
                            from: webSocketToNode,
                            request: fetchAtomsActionRequest
                        )
                    }^
            }
        
        let cancelFetch = nodeActionPublisher
            .compactMap(typeAs: FetchAtomsActionCancel.self)
//            .handleEvents(receiveOutput: {
//                self.cancellablesMap.removeValue(forKey: $0.uuid)?.cancel()
//            })
            .ignoreOutput(mapToType: NodeAction.self)
        
        return cancelFetch.merge(with: fetch)^
        
    }
}

private extension FetchAtomsEpic {
    func fetchAtoms(from webSocketToNode: WebSocketToNode, request: FetchAtomsActionRequest) -> AnyPublisher<NodeAction, Never> {
        //        let webSocketToNode = webSockets.newDisconnectedWebsocket(to: node)
        let node = webSocketToNode.node
        let rpcAtomsObserver = makeAtomsObserver(webSocketToNode) // DefaultRPCClient(channel: webSocketToNode)
        let rpcAtomsObservingCanceller = makeAtomsObservationCanceller(webSocketToNode)
        let uuid = request.uuid
        let subscriberIdFromUuid = SubscriberId(uuid: uuid)
        let address = request.address
        
        let atomsObservation: AnyPublisher<NodeAction, Never> = rpcAtomsObserver.observeAtoms(subscriberId: subscriberIdFromUuid)
            .map { observation in
                FetchAtomsActionObservation(address: address, node: node, atomObservation: observation, uuid: uuid) as NodeAction
            }^
        
        func cleanUp() {
            rpcAtomsObservingCanceller.cancelAtomsSubscription(subscriberId: subscriberIdFromUuid)
                .ignoreOutput()
                .andThen(Just(self.webSocketCloser.closeWebSocketToNode(node)))
                .sink { _ in }
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

