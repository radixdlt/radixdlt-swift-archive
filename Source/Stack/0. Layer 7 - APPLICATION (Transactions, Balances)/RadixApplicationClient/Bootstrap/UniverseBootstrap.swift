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

public struct UniverseBootstrap: BootstrapConfig {
    public let config: UniverseConfig
    public let discoveryMode: DiscoveryMode
}

private extension UniverseBootstrap {
    init(config: UniverseConfig, seedNodes: CombineObservable<Node>) {
        self.config = config
        self.discoveryMode = .byDiscovery(config: config, seedNodes: seedNodes)
    }
    
    init(config: UniverseConfig, originNode: Node, nodes: Node...) {
        self.config = config
        self.discoveryMode = .byOriginNode(originNode, nodes: nodes)
    }
}

// MARK: - CustomDebugStringConvertible
public extension UniverseBootstrap {
    var debugDescription: String {
        return """
        UniverseConfig: \(config.debugDescription),
        DiscoveryMode: \(discoveryMode.debugDescription)
        """
    }
}

// MARK: - Presets
public extension UniverseBootstrap {
    static var localhostTwoNodes: UniverseBootstrap {
        return UniverseBootstrap(
            config: .localnet,
            originNode: .localhostWebsocket(port: 8080),
            nodes: .localhostWebsocket(port: 8081)
        )
    }
    
    static var localhostSingleNode: UniverseBootstrap {
        return UniverseBootstrap(
            config: .localnet,
            originNode: .localhostWebsocket(port: 8080)
        )
    }
    
    static var `default`: UniverseBootstrap { localhostSingleNode }
    
//    static var betanet: UniverseBootstrap {
//        return UniverseBootstrap(
//            config: .betanet,
//            seedNodes: OriginNodeFinder.betanet.findSomeOriginNode(port: .nodeFinder).asObservable()
//        )
//    }
}

private extension Node {
    static func localhostWebsocket(port: Port) -> Node {
        do {
            return try Node(host: Host.local(port: port), isUsingSSL: false)
        } catch { incorrectImplementation("should be able to create localhost node") }
    }
}
