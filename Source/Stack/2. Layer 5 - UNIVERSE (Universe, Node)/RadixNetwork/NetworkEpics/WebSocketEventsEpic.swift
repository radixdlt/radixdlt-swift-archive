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
import Combine

// TODO: this should not be an epic
public final class WebSocketEventsEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsManager
    public init(webSockets: WebSocketsManager) {
        self.webSockets = webSockets
    }
}

public extension WebSocketEventsEpic {
    
    // TODO neither `actions` nor `networkState` is used, thus this should not be an epic
    func handle(
        actions _: AnyPublisher<NodeAction, Never>,
        networkState _: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        return webSockets.getNewSocketsToNode().flatMap { webSocketToNode in
            webSocketToNode.webSocketStatus.map { webSocketStatus in
                WebSocketEvent(node: webSocketToNode.node, webSocketStatus: webSocketStatus)
            }
        }.eraseToAnyPublisher()
    }
}

