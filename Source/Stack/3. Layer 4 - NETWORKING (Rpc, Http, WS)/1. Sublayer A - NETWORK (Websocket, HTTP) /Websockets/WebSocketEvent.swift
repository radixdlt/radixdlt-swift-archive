//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
