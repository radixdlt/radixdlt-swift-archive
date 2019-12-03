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

// MARK: DefaultWebSocketsManager
public final class DefaultWebSocketsManager: WebSocketsManager {
    
    private let newSocketsToNodeSubject: PassthroughSubject<WebSocketToNode, Never>
    private var webSockets = [Node: WebSocketToNode]()
    
    public init() {
        self.newSocketsToNodeSubject = PassthroughSubject()
    }
}

// MARK: WebSocketsManager
public extension DefaultWebSocketsManager {
    
    func observeNewSockets() -> AnyPublisher<WebSocketToNode, Never> {
        newSocketsToNodeSubject.eraseToAnyPublisher()
    }
    
    @discardableResult
    func newSockets(to node: Node) -> WebSocketToNode {
        return webSockets.valueForKey(key: node) { [weak newSocketsToNodeSubject] in
            let newSocket = WebSocketToNode(node: node)
            newSocketsToNodeSubject?.send(newSocket)
            return newSocket
        }
    }
  
    @discardableResult
    func tryCloseSocketTo(node: Node, strategy: WebSocketClosingStrategy) -> AnyPublisher<CloseWebSocketResult, Never> {
        guard let webSocket = webSockets[node] else {
            return Just(.didNotClose(reason: .foundNoSocketForNode(node))).eraseToAnyPublisher()
        }
        
        return Publishers.Throttle(
            upstream: Just<CloseWebSocketResult>(tryClose(socket: webSocket, strategy: strategy)),
            interval: 10,
            scheduler: RadixSchedulers.mainThreadScheduler,
            latest: true
        )
            .eraseToAnyPublisher()
    }
}

private extension DefaultWebSocketsManager {
    @discardableResult
    func tryClose(socket: WebSocketToNode, strategy: WebSocketClosingStrategy) -> CloseWebSocketResult {
        let result = socket.close(strategy: strategy)
        if result.didClose {
            webSockets.removeValue(forKey: socket.node)
        }
        return result
    }
}

public enum CloseWebSocketResult {
    case closed
    indirect case didNotClose(reason: Reason)
    
}

public extension CloseWebSocketResult {
    enum Reason {
        case isInUse
        case foundNoSocketForNode(Node)
    }
    
    var didClose: Bool {
        switch self {
        case .closed: return true
        case .didNotClose: return false
        }
    }
}
