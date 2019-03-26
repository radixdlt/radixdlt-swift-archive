//
//  WebSocketEvent.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct WebSocketEvent: NodeAction {
    public let node: Node
    public let websocketStatus: WebSocketStatus
}
