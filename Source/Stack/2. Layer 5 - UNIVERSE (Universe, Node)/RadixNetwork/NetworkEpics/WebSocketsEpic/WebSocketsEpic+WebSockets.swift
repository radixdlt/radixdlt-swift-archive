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

// MARK: WebSockets
public extension WebSocketsEpic {
    final class WebSockets {
        
        private let newSocketsToNodeSubject: PassthroughSubject<WebSocketToNode, Never>
        
        private var webSockets = [Node: WebSocketToNode]()
        fileprivate init() {
            self.newSocketsToNodeSubject = PassthroughSubject()
        }
    }
}

internal extension WebSocketsEpic.WebSockets {
    
    func getNewSocketsToNode() -> AnyPublisher<WebSocketToNode, Never> {
        return newSocketsToNodeSubject.eraseToAnyPublisher()
    }
    
    @discardableResult
    func newDisconnectedWebsocket(to node: Node) -> WebSocketToNode {
        return webSockets.valueForKey(key: node) { [unowned self] in
            let newSocket = WebSocketToNode(node: node)
            self.newSocketsToNodeSubject.send(newSocket)
            return newSocket
        }
    }
    
    func ifNoOneListensCloseAndRemoveWebsocket(toNode node: Node, afterDelay delay: DispatchTimeInterval? = nil) {
        guard let webSocket = webSockets[node] else { return }
        ifNoOneListensCloseAndRemove(webSocket: webSocket, afterDelay: delay)
    }
    
    func ifNoOneListensCloseAndRemove(webSocket: WebSocketToNode, afterDelay delay: DispatchTimeInterval?) {
        if let delay = delay {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) { [unowned self] in
                self.ifNoOneListensCloseAndRemove(webSocket: webSocket)
            }
        } else {
            ifNoOneListensCloseAndRemove(webSocket: webSocket)
        }
    }
    
    func ifNoOneListensCloseAndRemove(webSocket: WebSocketToNode) {
        guard webSocket.closeIfNoOneListens() else { return }
        webSockets.removeValue(forKey: webSocket.node)
    }
}
