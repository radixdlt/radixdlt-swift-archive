//
//  DefaultAPIClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public enum Communcation {
    case hypertext
    case websocket
}

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
    
    init(seeds: Observable<[Node]> = Observable.empty()) {
        
        // Node discovery
        self.nodes = Observable.merge(seeds, nodesSubject.asObservable()).filter { !$0.isEmpty }
        
        // REST
        self.restClient = self.nodes.map {
            DefaultRESTClient(baseURL: $0[0].url)
        }
        
        // Websocket
        let webSocketToNode: Observable<WebSocketToNode> = self.nodes.map {
            WebSocketToNode(node: $0[0])
        }
        
        self.websocketStatus = webSocketToNode.flatMapLatest { $0.state }
        
        self.jsonRpcClient = webSocketToNode.map {
             DefaultRadixJsonRpcClient(persistentChannel: $0)
        }
    }
}

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
