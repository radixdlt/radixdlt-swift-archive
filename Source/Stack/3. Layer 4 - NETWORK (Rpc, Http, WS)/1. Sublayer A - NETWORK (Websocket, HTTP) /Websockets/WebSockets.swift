//
//  WebSockets.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// TODO Fix memory life cycle in a way that does not requires this singleton

/// All websockets are created and managed here
public final class WebSockets {
    public static let shared = WebSockets()
    private var webSockets = [Node: WebSocketToNode]()
    public init() {}
    public class func webSocket(to node: Node) -> WebSocketToNode {
        return WebSockets.shared.webSockets.valueForKey(key: node) {
            WebSocketToNode(node: node)
        }
    }
}
