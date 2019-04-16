//
//  JSONRPCClients.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// TODO Fix memory life cycle in a way that does not requires this singleton

/// All JSONRPCClients are created and managed here
public final class JSONRPCClients {
    public static let shared = JSONRPCClients()
    private var clients: [Node: DefaultRPCClient] = [:]
    public init() {}
    public class func rpcClient(websocket: WebSocketToNode) -> DefaultRPCClient {
        return JSONRPCClients.shared.clients.valueForKey(key: websocket.node) {
            DefaultRPCClient(channel: websocket)
        }
    }
}

// TODO Fix memory life cycle in a way that does not requires this singleton

/// All JSONRPCClients are created and managed here
public final class RESTClientsRetainer {
    public static let shared = RESTClientsRetainer()
    private var clientsForNodeUrl: [FormattedURL: DefaultRESTClient] = [:]
    public init() {}
    public class func restClient(urlToNode: FormattedURL) -> DefaultRESTClient {
        return RESTClientsRetainer.shared.clientsForNodeUrl.valueForKey(key: urlToNode) {
            DefaultRESTClient(url: urlToNode)
        }
    }
}
