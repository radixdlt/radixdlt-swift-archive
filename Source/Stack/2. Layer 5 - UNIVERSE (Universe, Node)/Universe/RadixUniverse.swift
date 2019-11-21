//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import Combine

public protocol RadixUniverse {
    
    var atomStore: AtomStore { get }
    var atomPuller: AtomPuller { get }
    var config: UniverseConfig { get }
    var networkController: RadixNetworkController { get }
    var nativeTokenDefinition: TokenDefinition { get }
}

public extension RadixUniverse {
    var connectedNodes: AnyPublisher<[RadixNodeState], Never> { networkController.connectedNodes }
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
    
    static func makeNetworkEpics(
        discoveryMode: DiscoveryMode,
        determineIfPeerIsSuitable: DetermineIfPeerIsSuitable
    ) -> [RadixNetworkEpic] {
        return makeNetworkEpics(
            discoveryEpics: discoveryMode.radixNetworkEpics,
            determineIfPeerIsSuitable: determineIfPeerIsSuitable
        )
    }
    
    static func makeNetworkEpics(
        discoveryEpics: [RadixNetworkEpic],
        determineIfPeerIsSuitable: DetermineIfPeerIsSuitable
    ) -> [RadixNetworkEpic] {
        var networkEpics = makeNetworkEpics(determineIfPeerIsSuitable: determineIfPeerIsSuitable)
        networkEpics.append(contentsOf: discoveryEpics)
        return networkEpics
    }
    
    static func makeNetworkEpics(
        determineIfPeerIsSuitable: DetermineIfPeerIsSuitable
    ) -> [RadixNetworkEpic] {
        
        return [
            WebSocketsEpic.init(epicFromWebsocketMakers: [
                WebSocketEventsEpic.init(webSockets:),
                ConnectWebSocketEpic.init(webSockets:),
                SubmitAtomEpic.init(webSockets:),
                FetchAtomsEpic.init(webSockets:),
                RadixJsonRpcMethodEpic<GetLivePeersActionRequest, GetLivePeersActionResult>.createGetLivePeersEpic(webSockets:),
                RadixJsonRpcMethodEpic<GetNodeInfoActionRequest, GetNodeInfoActionResult>.createGetNodeInfoEpic(webSockets:),
                RadixJsonRpcMethodEpic<GetUniverseConfigActionRequest, GetUniverseConfigActionResult>.createUniverseConfigEpic(webSockets:),
                RadixJsonRpcAutoConnectEpic.init(webSockets:),
                RadixJsonRpcAutoCloseEpic.init(webSockets:)
            ]),
            FindANodeEpic(
                determineIfPeerIsSuitable: determineIfPeerIsSuitable
            )
        ]
    }

    convenience init(config: UniverseConfig, discoveryMode: DiscoveryMode) throws {
       let atomStore = InMemoryAtomStore(genesisAtoms: config.genesis.atoms)

        let initialNetworkOfNodes = discoveryMode.initialNetworkOfNodes
     
        let networkEpics = DefaultRadixUniverse.makeNetworkEpics(
            discoveryMode: discoveryMode,
            determineIfPeerIsSuitable: .ifShardSpaceIntersectsWithShards(isUniverseSuitable: .ifEqual(to: config))
        )
        
        let networkController = try DefaultRadixNetworkController(
            network: DefaultRadixNetwork(state: RadixNetworkState(nodesDisconnectFromWS: initialNetworkOfNodes.contents)),
            epics: networkEpics,
            nodeActionReducers: [SomeReducer(InMemoryAtomStoreReducer(atomStore: atomStore))]
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
            incorrectImplementationShouldAlwaysBeAble(to: "Create a `RadixUniverse` from a boot strap config", error)
        }
    }
}

public extension DefaultRadixUniverse {

    func addressFrom(account: Account) -> Address {
        return account.addressFromMagic(config.magic)
    }
}

private extension RadixNetworkState {
    init(nodesDisconnectFromWS nodes: [Node]) {
        self.init(nodeStates: nodes.map { RadixNodeState.disconnected(from: $0) })
    }
}

extension RadixNodeState {
    
    static func of(node: Node, webSocketStatus: WebSocketStatus) -> Self {
        do {
            return try Self(node: node, webSocketStatus: webSocketStatus)
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
    }
    
    static func disconnected(from node: Node) -> Self {
        of(node: node, webSocketStatus: .disconnected)
    }
}
