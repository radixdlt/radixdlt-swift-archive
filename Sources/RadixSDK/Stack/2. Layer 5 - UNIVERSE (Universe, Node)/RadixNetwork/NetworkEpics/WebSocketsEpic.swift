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

public protocol NetworkWebsocketEpic: RadixNetworkEpic {
    var webSockets: WebSocketsEpic.WebSockets { get }
    init(webSockets: WebSocketsEpic.WebSockets)
}
public extension NetworkWebsocketEpic {
    init(webSockets: WebSocketsEpic.WebSockets) {
        abstract()
    }
}

public extension NetworkWebsocketEpic {
    func waitForConnection(toNode node: Node) -> CombineCompletable {
        let websocketToNode = webSockets.webSocket(to: node, shouldConnect: true)
        return websocketToNode.waitForConnection()
    }
    
    func waitForConnectionReturnWS(toNode node: Node) -> CombineSingle<WebSocketToNode> {
        
//        let websocketToNode = webSockets.webSocket(to: node, shouldConnect: true)
//
//        return websocketToNode.waitForConnection()
//            .andThen(
//                CombineSingle.just(websocketToNode)
//        )
        
        combineMigrationInProgress()
    }
    
    func close(webSocketToNode: WebSocketToNode, useDelay: Bool = false) {
        let delay: DispatchTimeInterval? = useDelay ? delayFromCancelObservationOfAtomStatusToClosingWebsocket : nil
        webSockets.ifNoOneListensCloseAndRemove(websocket: webSocketToNode, afterDelay: delay)
    }
    
    func closeWebsocketTo(node: Node, useDelay: Bool = false) {
        let delay: DispatchTimeInterval? = useDelay ? delayFromCancelObservationOfAtomStatusToClosingWebsocket : nil
        webSockets.ifNoOneListensCloseAndRemoveWebsocket(toNode: node, afterDelay: delay)
    }
}

public final class WebSocketsEpic: RadixNetworkEpic {
    public typealias EpicFromWebSocket = (WebSockets) -> NetworkWebsocketEpic
    public typealias EpicsFromWebSockets = [EpicFromWebSocket]
    private let epicFromWebsockets: EpicsFromWebSockets

    private var _retainingVariableEpics = [NetworkWebsocketEpic]()
    
    public init(epicFromWebsockets: EpicsFromWebSockets) {
        self.epicFromWebsockets = epicFromWebsockets
    }
}

public extension WebSocketsEpic {
    func epic(
        actions: CombineObservable<NodeAction>,
        networkState: CombineObservable<RadixNetworkState>
    ) -> CombineObservable<NodeAction> {
        
//        let webSockets = WebSockets()
//        return CombineObservable.merge(
//            epicFromWebsockets
//                .map { [unowned self] epicFromWebSocket in
//                    let newEpic = epicFromWebSocket(webSockets)
//                    self._retainingVariableEpics.append(newEpic)
//                    return newEpic
//                }
//                .map { (newlyCreatedEpic: NetworkWebsocketEpic) -> CombineObservable<NodeAction> in
//                    return newlyCreatedEpic.epic(actions: actions, networkState: networkState)
//                }
//        )
        combineMigrationInProgress()
    }
}

public extension WebSocketsEpic {
    final class WebSockets {
        private let newSocketsToNodeSubject: PassthroughSubjectNoFail<WebSocketToNode>
        private var webSockets = [Node: WebSocketToNode]()
        fileprivate init() {
            self.newSocketsToNodeSubject = PassthroughSubjectNoFail()
        }
    }
}

internal extension WebSocketsEpic.WebSockets {
    
    func getNewSocketsToNode() -> CombineObservable<WebSocketToNode> {
        return newSocketsToNodeSubject.eraseToAnyPublisher()
    }
    
    @discardableResult
    func webSocket(to node: Node, shouldConnect: Bool) -> WebSocketToNode {
        return webSockets.valueForKey(key: node) { [unowned self] in
            let newSocket = WebSocketToNode(node: node, shouldConnect: shouldConnect)
            self.newSocketsToNodeSubject.send(newSocket)
            return newSocket
        }
    }
    
    func ifNoOneListensCloseAndRemoveWebsocket(toNode node: Node, afterDelay delay: DispatchTimeInterval? = nil) {
        guard let websocket = webSockets[node] else { return }
        ifNoOneListensCloseAndRemove(websocket: websocket, afterDelay: delay)
    }
    
    func ifNoOneListensCloseAndRemove(websocket: WebSocketToNode, afterDelay delay: DispatchTimeInterval?) {
        if let delay = delay {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) { [unowned self] in
                self.ifNoOneListensCloseAndRemove(websocket: websocket)
            }
        } else {
            ifNoOneListensCloseAndRemove(websocket: websocket)
        }
    }
    
    func ifNoOneListensCloseAndRemove(websocket: WebSocketToNode) {
        guard websocket.closeIfNoOneListens() else { return }
        webSockets.removeValue(forKey: websocket.node)
    }
}
