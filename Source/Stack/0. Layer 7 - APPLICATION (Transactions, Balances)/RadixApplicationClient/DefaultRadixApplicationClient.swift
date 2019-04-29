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
    public let identity: RadixIdentity
    
    private init(nodeInteractor: NodeInteraction, identity: RadixIdentity) {
        self.nodeInteractor = nodeInteractor
        self.identity = identity
    }
}

public extension DefaultRadixApplicationClient {
    
    convenience init(_ nodeDiscovery: NodeDiscovery, identity: RadixIdentity) {
        self.init(
            nodeInteractor: DefaultNodeInteraction(nodeDiscovery),
            identity: identity
        )
    }
    
    convenience init(node: NodeDiscoveryHardCoded, identity: RadixIdentity) {
        self.init(node, identity: identity)
    }
}
