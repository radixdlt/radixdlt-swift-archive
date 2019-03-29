//
//  DefaultAPIClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultAPIClient {

    // MARK: - Node Discovery
    private let nodesSubject = PublishSubject<[Node]>()
    private let nodes: Observable<[Node]>

    // MARK: - REST
    private let restClient: Observable<DefaultRESTClient>
    
    // MARK: - Websocket
    private let jsonRpcClient: Observable<DefaultRadixJsonRpcClient>
    public let websocketStatus: Observable<WebSocketStatus>

    init(nodeDiscovery: NodeDiscovery) {
        
        // Node discovery
        let seedNodes = nodeDiscovery.loadNodes()
        self.nodes = Observable.merge(seedNodes, nodesSubject.asObservable()).filter { !$0.isEmpty }
        
        // REST
        self.restClient = self.nodes.map {
            DefaultRESTClient(baseURL: $0[0].url)
        }
        
        // Websocket
        let websocket = self.nodes.map {
            WebSockets.webSocket(to: $0[0])
        }
        self.websocketStatus = websocket.flatMapLatest { $0.state }
        
        self.jsonRpcClient = websocket.map { (socketToNode: WebSocketToNode) -> DefaultRadixJsonRpcClient in
            JSONRPCClients.rpcClient(websocket: socketToNode)
        }
    }
    
    deinit {
        log.warning("Deinit (might be relevant until life cycle is proper fixed)")
    }
}

// MARK: - Connect to new node
public extension DefaultAPIClient {
    func connectToNode(_ node: Node) {
        nodesSubject.onNext([node])
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
    
    func getUniverse() -> Observable<UniverseConfig> {
        return jsonRpcClient.flatMapLatest { $0.getUniverse() }
    }
    
    func pull(from address: Address) -> Observable<AtomSubscription> {
        let atomsQuery = AtomQuery(address: address)
        return jsonRpcClient.flatMapLatest {
            $0.getAtoms(query: atomsQuery)
                .asObservable()
        }
    }
    
    func balance(forAddress address: Address, token: TokenDefinitionReference) -> Observable<TokenBalance> {
        return pull(from: address)
            .map { $0.update }.filterNil()
            .map { $0.atomEvents.compactMap { $0.store } }
            .map { $0.map { $0.atom.tokensBalances() } }
            .scan(TokenBalances(), accumulator: ({ (tokenBalance: TokenBalances, tokenBalances: [TokenBalances]) -> TokenBalances in
                try tokenBalances.reduce(tokenBalance, { try $0.merging(with: $1) })
            })).map {
                $0.balanceOrZero(of: token, address: address)
        }
    }
    
    func submit(atom: Atom) -> Observable<SubmitAtomAction> {
        implementMe
    }
}
