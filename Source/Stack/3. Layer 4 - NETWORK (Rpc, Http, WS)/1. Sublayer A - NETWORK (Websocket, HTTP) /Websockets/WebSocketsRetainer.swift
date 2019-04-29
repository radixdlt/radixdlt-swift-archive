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
public final class WebSocketsRetainer {
    public static let shared = WebSocketsRetainer()

    private var webSockets = [Node: WebSocketToNode]()
    private init() {}
}

// MARK: - Public Class Methods
public extension WebSocketsRetainer {
    class func webSocket(to node: Node) -> WebSocketToNode {
        return shared.webSocket(to: node)
    }
    
}

// MARK: - Private Instance Methods
private extension WebSocketsRetainer {
    func webSocket(to node: Node) -> WebSocketToNode {
        return webSockets.valueForKey(key: node) {
            WebSocketToNode(node: node)
        }
    }
}
