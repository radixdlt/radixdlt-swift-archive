//
//  WebSockets.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// All websockets are created and managed here
public final class WebSockets {
    private var webSockets = [Node: WebSocketToNode]()
    public init() {}
    public func webSocket(to node: Node) -> WebSocketToNode {
        return webSockets.valueForKey(key: node) {
            WebSocketToNode(node: node)
        }
    }
}
