//
//  WebSocketEvent.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-03.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct WebSocketEvent: RadixNetworkNodeAction {
    public let node: Node
    public let eventType: EventType
    private init(node: Node, eventType: EventType) {
        self.node = node
        self.eventType = eventType
    }
}

public extension WebSocketEvent {
    init(node: Node, webSocketStatus: WebSocketStatus) {
        self.init(node: node, eventType: EventType(status: webSocketStatus))
    }
}

public extension WebSocketEvent {
    enum EventType {
        case disconnected
        
        case connecting
//        case connected
        case ready
        
        case closing
        case failed
    }
    
    var webSocketStatus: WebSocketStatus {
        return eventType.asWebSocketStatus
    }
}

private extension WebSocketEvent.EventType {
    init(status: WebSocketStatus) {
        switch status {
        case .disconnected: self = .disconnected
            
        case .connecting: self = .connecting
//        case .connected: self = .connected
        case .ready: self = .ready
            
        case .closing: self = .closing
        case .failed: self = .failed
        }
    }
    
    var asWebSocketStatus: WebSocketStatus {
        switch self {
        case .disconnected: return .disconnected
            
        case .connecting: return .connecting
//        case .connected: return .connected
        case .ready: return .ready
            
        case .closing: return .closing
        case .failed: return .failed
        }
    }
}
