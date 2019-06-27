//
//  RadixUniverse.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol RadixUniverse {
    
    var atomStore: AtomStore { get }
    var atomPuller: AtomPuller { get }
    var config: UniverseConfig { get }
    var networkController: RadixNetworkController { get }
    var nativeTokenDefinition: TokenDefinition { get }
    
    func connectToNode(nodeFinding: NodeFindingg, account: Account) -> Completable
    func connectToNode(address: Address) -> Completable
}

// MARK: - RadixUniverse
public final class DefaultRadixUniverse: RadixUniverse {
    
    public let config: UniverseConfig
    public let networkController: RadixNetworkController
    public let nativeTokenDefinition: TokenDefinition
    public let atomStore: AtomStore
    public let atomPuller: AtomPuller
    
    public init(config: UniverseConfig, networkController: RadixNetworkController, atomStore: AtomStore) throws {
        self.config = config
        self.networkController = networkController
        self.nativeTokenDefinition = try config.nativeTokenDefinition()
        self.atomPuller = DefaultAtomPuller(networkController: networkController)
        self.atomStore = atomStore
    }
}

public extension DefaultRadixUniverse {

    convenience init(config: UniverseConfig, nodeFinding: NodeFindingg) throws {
        let atomStore = InMemoryAtomStore(genesisAtoms: config.genesis.atoms)
        
        let networkController = DefaultRadixNetworkController(
            nodeFinding: nodeFinding,
            reducers: [SomeReducer<NodeAction>(InMemoryAtomStoreReducer(atomStore: atomStore))]
        )
        
        try self.init(config: config, networkController: networkController, atomStore: atomStore)
    }
    
    convenience init(bootstrapConfig: BootstrapConfig) {
        do {
            try self.init(
                config: bootstrapConfig.config,
                nodeFinding: bootstrapConfig.nodeFinding
            )
        } catch {
            incorrectImplementation("Should always be able to create RadixUniverse from bootstrap config")
        }
    }
}

public extension DefaultRadixUniverse {
    func connectToNode(nodeFinding: NodeFindingg, account: Account) -> Completable {
        let address = addressFrom(account: account)
        return networkController.connectToNode(nodeFinding: nodeFinding, address: address)
    }
    
    func connectToNode(address: Address) -> Completable {
        return networkController.connectToNode(address: address)
    }
    
    func addressFrom(account: Account) -> Address {
        return account.addressFromMagic(config.magic)
    }
}
