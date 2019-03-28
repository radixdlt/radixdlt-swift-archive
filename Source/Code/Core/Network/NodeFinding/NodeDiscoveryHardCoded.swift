//
//  NodeDiscoveryHardCoded.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct NodeDiscoveryHardCoded: NodeDiscovery {
    private let hardCodedNodes: [Node]
    public init(hardCodedNodes: [Node]) {
        self.hardCodedNodes = hardCodedNodes
    }
    
    public init(_ hardCodedNodes: Node...) {
        self.hardCodedNodes = hardCodedNodes
    }
    
    public func loadNodes() -> Observable<[Node]> {
        return Observable.of(hardCodedNodes)
    }
}
