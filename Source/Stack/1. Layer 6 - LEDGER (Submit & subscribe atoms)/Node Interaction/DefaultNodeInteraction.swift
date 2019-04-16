//
//  DefaultNodeInteraction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultNodeInteraction: NodeInteraction {
    private let nodeConnection: NodeConnection
    public init(connectedToNode: NodeConnection) {
        self.nodeConnection = connectedToNode
    }
}

// MARK: - Concenience init
public extension DefaultNodeInteraction {
    convenience init(node: Node) {
        self.init(connectedToNode: DefaultNodeConnection(node: node))
    }
}

// MARK: - NodeInteraction
public extension DefaultNodeInteraction {
    
    func subscribe(to address: Address) -> Observable<AtomSubscription> {
        // TODO: handle subscription!
        return nodeConnection.rpcClient.getAtoms(for: address)
    }
    
    func submit(atom: Atom) -> Observable<AtomSubscription> {
        // TODO: handle subscription!
        return nodeConnection.rpcClient.submitAtom(atom)
    }
    
    func unsubscribe(from address: Address) -> Completable {
        implementMe
    }
    
    func unsubscribeAll() -> Completable {
        implementMe
    }
    
}
