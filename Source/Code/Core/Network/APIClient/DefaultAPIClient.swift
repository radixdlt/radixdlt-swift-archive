//
//  DefaultAPIClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultAPIClient: APIClient {

    // MARK: - Node Discovery
    private let nodesSubject = PublishSubject<[Node]>()
    private let nodes: Observable<[Node]>

    // MARK: - REST
    private let restClient: Observable<RESTClient>
    
    // MARK: - Websocket
    private let jsonRpcClient: Observable<RadixJsonRpcClient>
    private let websocketStatus: Observable<WebSocketStatus>

    private let bag = DisposeBag()
    
    // swiftlint:disable:next function_body_length
    init(nodeDiscovery: NodeDiscovery) {
        
        // Node discovery
        let seedNodes = nodeDiscovery.loadNodes()
        self.nodes = Observable.merge(seedNodes, nodesSubject.asObservable()).filter { !$0.isEmpty }
        
        // REST
        self.restClient = self.nodes.map {
            DefaultRESTClient(baseURL: $0[0].url)
        }
        
        // Websocket
        let webSocketToNode: Observable<WebSocketToNode> = self.nodes.map {
            WebSockets.webSocket(to: $0[0])
        }
        
        self.websocketStatus = webSocketToNode.flatMapLatest { $0.state }
        
        let rpcClient = webSocketToNode.map { (socketToNode: WebSocketToNode) -> RadixJsonRpcClient in
            DefaultRadixJsonRpcClient(persistentChannel: socketToNode)
        }
        rpcClient.subscribe().disposed(by: bag)
        self.jsonRpcClient = rpcClient
    }
}

// MARK: - APIClient
public extension DefaultAPIClient {
    
    func livePeers(communcation: Communcation = .websocket) -> Observable<[NodeRunnerData]> {
        switch communcation {
        case .hypertext: return restClient.flatMapLatest { $0.request(router: NodeRouter.livePeers) }
        case .websocket: return jsonRpcClient.flatMapLatest { $0.getLivePeers().asObservable() }
        }
    }
    
    func pull(from address: Address) -> Observable<AtomObservation> {
        implementMe
    }
    
    func submit(atom: Atom) -> Observable<SubmitAtomAction> {
        implementMe
    }
}
