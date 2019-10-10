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
import RxSwift

public protocol RadixUniverse {
    
    var atomStore: AtomStore { get }
    var atomPuller: AtomPuller { get }
    var config: UniverseConfig { get }
    var networkController: RadixNetworkController { get }
    var nativeTokenDefinition: TokenDefinition { get }
}

public extension RadixUniverse {
    var readyNodes: Observable<[RadixNodeState]> { networkController.readyNodes }
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
            ]),
            FindANodeEpic()
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
    init(nodesDisconnectFromWS: [Node]) {
        self.init(nodes:
            nodesDisconnectFromWS
                .map { KeyValuePair<Node, RadixNodeState>(key: $0, value: .init(node: $0, webSocketStatus: .disconnected)) }
                .toDictionary()
        )
    }
}
