//
//  RadixUniverse.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class RadixUniverse {
    public let apiClient: APIClient
    public let config: UniverseConfig
    public let ledger: Ledger
    public let powToken: TokenDefinitionIdentifier
    public let nativeToken: TokenDefinitionIdentifier
    
    // swiftlint:disable:next function_body_length
    private init(config: UniverseConfig, apiClient: APIClient, ledger: Ledger? = nil) throws {
        self.config = config
        self.apiClient = apiClient
        guard let powToken = config.genesis.tokenDefinition(symbol: "POW", comparison: ==) else {
            throw Error.noPowToken
        }
        self.powToken = powToken

        guard let nativeToken = config.genesis.tokenDefinition(symbol: "POW", comparison: !=) else {
            throw Error.noNativeToken
        }
        self.nativeToken = nativeToken
        
        let inMemoryAtomStore = InMemoryAtomStore()
        
        config.genesis.atoms.forEach { atom in
            atom.publicKeys()
                .map { RadixUniverse.addressFrom(publicKey: $0, config: config) }
                .forEach { address in
                    inMemoryAtomStore.store(atom: AtomObservation.createStore(atom), for: address)
            }
        }
        
        self.ledger = ledger ?? DefaultLedger(
            atomPuller:
                DefaultAtomPuller(
                fetcher: apiClient.pull,
                storeAtom: inMemoryAtomStore.store
            ),
            atomSubmitter: apiClient,
            particleStore: DefaultParticleStore(atomStore: inMemoryAtomStore),
            atomStore: inMemoryAtomStore
        )
    }
}

// MARK: - Public
public extension RadixUniverse {
    
    static func bootstrap(_ bootstrapConfig: BootstrapConfig) throws -> RadixUniverse {
        return try bootstrap(config: bootstrapConfig.config, seeds: bootstrapConfig.seeds)
    }
    
    static func bootstrap(config: UniverseConfig, seeds: Observable<Node>) throws -> RadixUniverse {
        let apiClient = DefaultAPIClient()
        return try RadixUniverse(config: config, apiClient: apiClient)
    }
    
    static func addressFrom(publicKey: PublicKey, config: UniverseConfig) -> Address {
        return Address(publicKey: publicKey, universeConfig: config)
    }
}

public extension RadixUniverse {
    enum Error: Swift.Error {
        case noPowToken
        case noNativeToken
    }
}
