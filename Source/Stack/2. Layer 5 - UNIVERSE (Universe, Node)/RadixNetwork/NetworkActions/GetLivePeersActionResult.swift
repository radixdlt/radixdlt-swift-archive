//
//  GetLivePeersActionResult.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct GetLivePeersActionResult: JsonRpcResultAction {
    public let node: Node
    private let nodeInfos: [NodeInfo]
    
    public init(node: Node, result: Result) {
        self.node = node
        self.nodeInfos = result
    }
}

public extension GetLivePeersActionResult {
    typealias Result = [NodeInfo]
    var result: Result {
        return nodeInfos
    }
}
