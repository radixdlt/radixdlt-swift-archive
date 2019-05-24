//
//  DefaultRadixApplicationClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol IdentityHolder: Signing, PublicKeyOwner {
    var identity: RadixIdentity { get }
}

// MARK: - Signing
public extension IdentityHolder {
    var privateKey: PrivateKey {
        return identity.privateKey
    }
}

// MARK: - PublicKeyOwner
public extension IdentityHolder {
    var publicKey: PublicKey {
        return identity.publicKey
    }
}

// swiftlint:disable opening_brace

public final class DefaultRadixApplicationClient: RadixApplicationClient,
    IdentityHolder,
    NodeInteracting,
    Magical,
    AtomSigning
{
    // swiftlint:enable opening_brace

    public let nodeSubscriber: NodeInteractionSubscribing
    public let nodeUnsubscriber: NodeInteractionUnsubscribing
    public let nodeSubmitter: NodeInteractionSubmitting
    
    public let identity: RadixIdentity
    public let magic: Magic
    
    public init(
        nodeSubscriber: NodeInteractionSubscribing,
        nodeUnsubscriber: NodeInteractionUnsubscribing,
        nodeSubmitter: NodeInteractionSubmitting,
        identity: RadixIdentity,
        magic: Magic
    ) {
        self.nodeSubscriber = nodeSubscriber
        self.nodeUnsubscriber = nodeUnsubscriber
        self.nodeSubmitter = nodeSubmitter
        self.identity = identity
        self.magic = magic
    }
}

public extension DefaultRadixApplicationClient {
    
    convenience init(
        nodeInteractor: NodeInteraction,
        identity: RadixIdentity,
        magic: Magic
        ) {
        self.init(
            nodeSubscriber: nodeInteractor,
            nodeUnsubscriber: nodeInteractor,
            nodeSubmitter: nodeInteractor,
            identity: identity,
            magic: magic
        )
    }
    
    convenience init(
        _ nodeDiscovery: NodeDiscovery,
        identity: RadixIdentity,
        magic: Magic
        ) {
        self.init(
            nodeInteractor: DefaultNodeInteraction(nodeDiscovery),
            identity: identity,
            magic: magic
        )
    }
    
    convenience init(
        node: NodeDiscoveryHardCoded,
        identity: RadixIdentity,
        magic: Magic
    ) {
        self.init(node, identity: identity, magic: magic)
    }
}
