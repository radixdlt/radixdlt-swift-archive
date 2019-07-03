//
//  GetUniverseConfigActionResult.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct GetUniverseConfigActionResult: JsonRpcResultAction {
    public let node: Node
    private let universeConfig: UniverseConfig
    
    public init(node: Node, result: Result) {
        self.node = node
        self.universeConfig = result
    }
}

public extension GetUniverseConfigActionResult {
    typealias Result = UniverseConfig
    var result: Result {
        return universeConfig
    }
}
