//
//  NetworkState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct NetworkState: ExpressibleByDictionaryLiteral {
    public typealias Key = Node
    public typealias Value = NodeState
    public let nodes: [Key: Value]
}

public extension NetworkState {
    init(dictionaryLiteral nodes: (Key, Value)...) {
         self.init(nodes: Dictionary(uniqueKeysWithValues: nodes))
    }
}
