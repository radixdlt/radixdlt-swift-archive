//
//  AddNodeAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AddNodeAction: NodeAction, Hashable {
    public let node: Node
    public let nodeInfo: NodeInfo?
    
    public init(node: Node, nodeInfo: NodeInfo? = nil) {
        self.node = node
        self.nodeInfo = nodeInfo
    }
}
