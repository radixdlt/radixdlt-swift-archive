//
//  NetworkState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

public struct NetworkState:
    DictionaryConvertible,
    Equatable {
    // swiftlint:enable colon
    public typealias Key = Node
    public typealias Value = NodeState
    
    public let nodes: Map
    
    public init(dictionary nodes: Map) {
        self.nodes = nodes
    }
  
    public init(nodes: Map) {
        self.init(dictionary: nodes)
    }
}

public extension NetworkState {
    var dictionary: Map {
        return nodes
    }
}
