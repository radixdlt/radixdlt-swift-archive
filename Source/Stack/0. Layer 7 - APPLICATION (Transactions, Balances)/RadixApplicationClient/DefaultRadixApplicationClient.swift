//
//  DefaultRadixApplicationClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultRadixApplicationClient: RadixApplicationClient, NodeInteracting {

    public let nodeInteractor: NodeInteraction
    
    public init(nodeInteractor: NodeInteraction) {
        self.nodeInteractor = nodeInteractor
    }
}

public extension DefaultRadixApplicationClient {
    convenience init(node: Node) {
        self.init(nodeInteractor: DefaultNodeInteraction(node: node))
    }
}
