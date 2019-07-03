//
//  WebSocketStatus.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum WebSocketStatus: String, Hashable, CustomStringConvertible, CaseIterable {
    case disconnected
    
    case connecting
    case connected
    case ready

    case closing
    case failed
}

public extension WebSocketStatus {
    var isConnected: Bool {
        return statusIs(.connected)
    }
    
    var isReady: Bool {
        return statusIs(.ready)
    }

    var isDisconnected: Bool {
        return statusIs(.disconnected)
    }
    
    func statusIs(_ `case`: WebSocketStatus) -> Bool {
        return enumCase(is: `case`)
    }
}

public struct WebSocketEvent: NodeAction {
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
        case connected
        case ready
        
        case closing
        case failed
    }
}

private extension WebSocketEvent.EventType {
    init(status: WebSocketStatus) {
        switch status {
        case .disconnected: self = .disconnected

        case .connecting: self = .connecting
        case .connected: self = .connected
        case .ready: self = .ready

        case .closing: self = .closing
        case .failed: self = .failed
        }
    }
}

extension RawRepresentable where Self.RawValue: Equatable {
    func enumCase(is `case`: Self) -> Bool {
        return self.rawValue == `case`.rawValue
    }
}

extension CustomStringConvertible where Self: RawRepresentable, Self.RawValue == String {
    public var description: String {
        return rawValue
    }
}
