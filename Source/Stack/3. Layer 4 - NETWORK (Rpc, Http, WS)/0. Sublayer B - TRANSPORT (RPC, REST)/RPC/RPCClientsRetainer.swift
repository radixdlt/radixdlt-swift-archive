//
//  RPCClientsRetainer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// TODO Fix memory life cycle in a way that does not requires this singleton

/// All RPCClients are created and managed here
public final class RPCClientsRetainer {
    public static let shared = RPCClientsRetainer()

    private var clients: [Node: DefaultRPCClient] = [:]
    private init() {}
}

// MARK: - Public Class Methods
public extension RPCClientsRetainer {
    
    class func rpcClient(websocket: WebSocketToNode) -> DefaultRPCClient {
        return shared.rpcClient(websocket: websocket)
    }
    
    class func rpcClient(node: Node) -> RPCClient {
        return shared.rpcClient(node: node)
    }
    
}

// MARK: - Private Instance
private extension RPCClientsRetainer {
    func rpcClient(websocket: WebSocketToNode) -> DefaultRPCClient {
        return clients.valueForKey(key: websocket.node) {
            DefaultRPCClient(channel: websocket)
        }
    }
    
    func rpcClient(node: Node) -> RPCClient {
        let webSocketToNode = WebSocketsRetainer.webSocket(to: node)
        return rpcClient(websocket: webSocketToNode)
    }
}
