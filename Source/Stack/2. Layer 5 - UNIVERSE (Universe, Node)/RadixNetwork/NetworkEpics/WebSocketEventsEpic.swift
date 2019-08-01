//
//  WebSocketEventsEpic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class WebSocketEventsEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsEpic.WebSockets
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}

public extension WebSocketEventsEpic {
    func epic(actions: Observable<NodeAction>, networkState: Observable<RadixNetworkState>) -> Observable<NodeAction> {
        return webSockets.getNewSocketsToNode().flatMap { webSocketToNode in
            webSocketToNode.state.map { webSocketStatus in
                WebSocketEvent(node: webSocketToNode.node, webSocketStatus: webSocketStatus)
            }
        }
    }
}

