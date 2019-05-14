//
//  DefaultRadixApplicationClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol IdentityHolder {
    var identity: RadixIdentity { get }
}

public final class DefaultRadixApplicationClient: RadixApplicationClient, IdentityHolder, NodeInteracting {

    public let nodeSubscriber: NodeInteractionSubscribing
    public let nodeUnsubscriber: NodeInteractionUnsubscribing
    public let nodeSubmitter: NodeInteractionSubmitting
    
    public let identity: RadixIdentity
    
    public init(
        nodeSubscriber: NodeInteractionSubscribing,
        nodeUnsubscriber: NodeInteractionUnsubscribing,
        nodeSubmitter: NodeInteractionSubmitting,
        identity: RadixIdentity
    ) {
        self.nodeSubscriber = nodeSubscriber
        self.nodeUnsubscriber = nodeUnsubscriber
        self.nodeSubmitter = nodeSubmitter
        self.identity = identity
    }
}

public extension DefaultRadixApplicationClient {
    
    convenience init(nodeInteractor: NodeInteraction, identity: RadixIdentity) {
        self.init(
            nodeSubscriber: nodeInteractor,
            nodeUnsubscriber: nodeInteractor,
            nodeSubmitter: nodeInteractor,
            identity: identity
        )
    }
    
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
