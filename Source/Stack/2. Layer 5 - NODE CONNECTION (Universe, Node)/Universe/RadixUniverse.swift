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

    convenience init(config: UniverseConfig, discoveryMode: DiscoveryMode) throws {
        let atomStore = InMemoryAtomStore(genesisAtoms: config.genesis.atoms)

        let discoveryEpics: [RadixNetworkEpic]
        let initialNetworkOfNodes: Set<Node>
        
        switch discoveryMode {
        case .byDiscoveryEpics(let discoveryEpicsFromMode):
            discoveryEpics = discoveryEpicsFromMode.elements
            initialNetworkOfNodes = Set()
        case .byInitialNetworkOfNodes(let initialNetworkOfNodesFromMode):
            discoveryEpics = []
            initialNetworkOfNodes = initialNetworkOfNodesFromMode.asSet
        }
        
        var networkEpics: [RadixNetworkEpic] = [
            WebSocketsEpic.init(epicFromWebsockets: [
                WebSocketEventsEpic.init(webSockets:),
                ConnectWebSocketEpic.init(webSockets:),
                SubmitAtomEpic.init(webSockets:),
                FetchAtomsEpic.init(webSockets:),
                RadixJsonRpcMethodEpic<GetLivePeersActionRequest, GetLivePeersActionResult>.createGetLivePeersEpic(webSockets:),
                RadixJsonRpcMethodEpic<GetNodeInfoActionRequest, GetNodeInfoActionResult>.createGetNodeInfoEpic(webSockets:),
                RadixJsonRpcMethodEpic<GetUniverseConfigActionRequest, GetUniverseConfigActionResult>.createUniverseConfigEpic(webSockets:),
                RadixJsonRpcAutoConnectEpic.init(webSockets:),
                RadixJsonRpcAutoCloseEpic.init(webSockets:)
            ])
        ]
        
        networkEpics.append(contentsOf: discoveryEpics)
        
        let networkController = DefaultRadixNetworkController(
            network: DefaultRadixNetwork(),
            initialNetworkState: RadixNetworkState(nodesDisconnectFromWS: initialNetworkOfNodes.asArray),
            epics: networkEpics,
            reducers: [SomeReducer(InMemoryAtomStoreReducer(atomStore: atomStore))]
        )
        
        try self.init(config: config, networkController: networkController, atomStore: atomStore)
    }
    
    convenience init(bootstrapConfig: BootstrapConfig) {
        do {
            try self.init(
                config: bootstrapConfig.config,
                discoveryMode: bootstrapConfig.discoveryMode
            )
        } catch {
            incorrectImplementation("Should always be able to create RadixUniverse from bootstrap config")
        }
    }
}

public extension DefaultRadixUniverse {

    func addressFrom(account: Account) -> Address {
        return account.addressFromMagic(config.magic)
    }
}

private extension RadixNetworkState {
    init(nodesDisconnectFromWS: [Node]) {
        self.init(nodes:
            nodesDisconnectFromWS
                .map { KeyValuePair<Node, RadixNodeState>(key: $0, value: .init(node: $0, webSocketStatus: .disconnected)) }
                .toDictionary()
        )
    }
}
