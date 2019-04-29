//
//  DefaultNodeConnection.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class DefaultNodeConnection: NodeConnection {
    public let node: Node
    public let rpcClient: RPCClient
    public let restClient: RESTClient
    
    public init(
        node: Node,
        rpcClient: RPCClient? = nil,
        restClient: RESTClient? = nil
        ) {
        self.node = node
        self.rpcClient = rpcClient ?? DefaultRPCClient(channel: WebSocketsRetainer.webSocket(to: node))
        self.restClient = restClient ?? DefaultRESTClient(node: node)
    }
}

import RxSwift
public extension DefaultNodeConnection {
    static func byNodeDiscovery(_ nodeDiscovery: NodeDiscovery) -> Observable<DefaultNodeConnection> {
        return nodeDiscovery.loadNodes().map { nodes -> DefaultNodeConnection in
            let node = nodes[0]
            return DefaultNodeConnection(
                node: node,
                rpcClient: RPCClientsRetainer.rpcClient(node: node),
                restClient: RESTClientsRetainer.restClient(node: node)
            )
        }
    }
}
