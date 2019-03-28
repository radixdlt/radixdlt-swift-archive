//
//  NodeRouter.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum NodeRouter: String, Router {
    case livePeers = "network/peers/live"
    case peers = "network/peers/"
    case network
    case system
    case universe
    case ping
}
