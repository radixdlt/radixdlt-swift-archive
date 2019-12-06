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

public protocol WebSocketsManager: AnyObject {
    
    /// Creates a `disconnected` web socket, you need to connect to it manually. Also
    /// observe that you *should* notify subscribers (having called `observeNewSockets()`)
    /// about this new socket.
    @discardableResult
    func newSockets(to node: Node) -> WebSocketToNode
    
    /// Try to close any web socket to the node using the provided closing strategy
    @discardableResult
    func tryCloseSocketTo(node: Node, strategy: WebSocketClosingStrategy) -> AnyPublisher<CloseWebSocketResult, Never>
    
    /// Subscribe to this publisher to get notified about newly created sockets
    func observeNewSockets() -> AnyPublisher<WebSocketToNode, Never>

}

