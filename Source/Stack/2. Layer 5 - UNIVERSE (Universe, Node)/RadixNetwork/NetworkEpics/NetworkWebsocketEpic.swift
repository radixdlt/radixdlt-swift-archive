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

// MARK: NetworkWebsocketEpic
public protocol NetworkWebsocketEpic: RadixNetworkEpic {
    var webSockets: WebSocketsEpic.WebSockets { get }
    init(webSockets: WebSocketsEpic.WebSockets)
}
public extension NetworkWebsocketEpic {
    init(webSockets: WebSocketsEpic.WebSockets) {
        abstract() // TODO delete this initializer, improve the use of this protocol
    }
}

public extension NetworkWebsocketEpic {
    func openWebSocketToNodeAndWait(toNode node: Node) -> Future<Void, Never> {
        let webSocketToNode = webSockets.newDisconnectedWebsocket(to: node)
        return webSocketToNode.connectAndNotifyWhenConnected()
    }
    
    // TODO: Precision should return `Single`?
    func waitForConnectionReturnWS(toNode node: Node) -> AnyPublisher<WebSocketToNode, Never> {
        
//        let webSocketToNode = webSockets.webSocket(to: node, shouldConnect: true)
//
//        return webSocketToNode.waitForConnection()
//            .andThen(
//                AnyPublisher.just(webSocketToNode)
//        )
        
        combineMigrationInProgress()
    }
    
    func close(webSocketToNode: WebSocketToNode, useDelay: Bool = false) {
        let delay: DispatchTimeInterval? = useDelay ? delayFromCancelObservationOfAtomStatusToClosingWebsocket : nil
        webSockets.ifNoOneListensCloseAndRemove(webSocket: webSocketToNode, afterDelay: delay)
    }
    
    func closeWebsocketTo(node: Node, useDelay: Bool = false) {
        let delay: DispatchTimeInterval? = useDelay ? delayFromCancelObservationOfAtomStatusToClosingWebsocket : nil
        webSockets.ifNoOneListensCloseAndRemoveWebsocket(toNode: node, afterDelay: delay)
    }
}
