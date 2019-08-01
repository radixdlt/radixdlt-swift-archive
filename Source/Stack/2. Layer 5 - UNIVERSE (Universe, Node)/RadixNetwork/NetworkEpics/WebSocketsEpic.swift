//
//  WebSocketsEpic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

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
    func waitForConnection(toNode node: Node) -> Completable {
        let websocketToNode = webSockets.webSocket(to: node, shouldConnect: true)
        return websocketToNode.waitForConnection()
    }
    
    func waitForConnectionReturnWS(toNode node: Node) -> Single<WebSocketToNode> {
        let websocketToNode = webSockets.webSocket(to: node, shouldConnect: true)
        return websocketToNode.waitForConnection().andThen(Single.just(websocketToNode))
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
    public typealias EpicsFromWebSockets = [Function<WebSockets, NetworkWebsocketEpic>]
    private let epicFromWebsockets: EpicsFromWebSockets

    private var _retainingVariableEpics = [NetworkWebsocketEpic]()
    
    public init(epicFromWebsockets: [(WebSockets) -> NetworkWebsocketEpic]) {
        self.epicFromWebsockets = epicFromWebsockets.map { Function($0) }
    }
}

public extension WebSocketsEpic {
    func epic(actions: Observable<NodeAction>, networkState: Observable<RadixNetworkState>) -> Observable<NodeAction> {
        let webSockets = WebSockets()
        return Observable.merge(
            epicFromWebsockets
                .map { [unowned self] in
                    let newEpic = $0.apply(webSockets)
                    self._retainingVariableEpics.append(newEpic)
                    return newEpic
                }
                .map { (newlyCreatedEpic: NetworkWebsocketEpic) -> Observable<NodeAction> in
                    return newlyCreatedEpic.epic(actions: actions, networkState: networkState)
                }
        )
    }
}

public extension WebSocketsEpic {
    final class WebSockets {
        private let newSocketsToNodeSubject: PublishSubject<WebSocketToNode>
        private var webSockets = [Node: WebSocketToNode]()
        fileprivate init() {
            self.newSocketsToNodeSubject = PublishSubject()
        }
    }
}

internal extension WebSocketsEpic.WebSockets {
    
    func getNewSocketsToNode() -> Observable<WebSocketToNode> {
        return newSocketsToNodeSubject.asObservable()
    }
    
    @discardableResult
    func webSocket(to node: Node, shouldConnect: Bool) -> WebSocketToNode {
        return webSockets.valueForKey(key: node) { [unowned self] in
            let newSocket = WebSocketToNode(node: node, shouldConnect: shouldConnect)
            self.newSocketsToNodeSubject.onNext(newSocket)
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
