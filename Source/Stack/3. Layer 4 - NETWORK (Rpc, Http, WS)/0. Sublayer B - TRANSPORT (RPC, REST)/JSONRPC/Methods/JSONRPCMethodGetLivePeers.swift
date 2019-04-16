//
//  JSONRPCMethodGetLivePeers.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct JSONRPCMethodGetLivePeers: JSONRPCKit.Request {
    public typealias Response = [NodeInfo]
    public let method = "Network.getLivePeers"
}
