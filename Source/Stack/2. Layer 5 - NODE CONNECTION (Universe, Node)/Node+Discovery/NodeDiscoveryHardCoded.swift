//
//  NodeDiscoveryHardCoded.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class NodeDiscoveryHardCoded: NodeDiscovery, SuitableNodeDiscovering {
    public typealias Error = NodeDiscoveryError
    private let urls: [FormattedURL]
    private let expectedUniverseConfig: UniverseConfig
    private let strategyIfUnsuitable: StrategyWhenNodeIsUnsuitable
    
    public init(formattedURLs: [FormattedURL], universeConfig: UniverseConfig, strategyIfUnsuitable: StrategyWhenNodeIsUnsuitable) {
        self.urls = formattedURLs
        self.expectedUniverseConfig = universeConfig
        self.strategyIfUnsuitable = strategyIfUnsuitable
    }
    
}

// MARK: - NodeDiscovery
public extension NodeDiscoveryHardCoded {
    
    convenience init(hosts: [Host], universeConfig: UniverseConfig, strategyIfUnsuitable: StrategyWhenNodeIsUnsuitable) throws {
        self.init(
            formattedURLs: try hosts.map {
                try URLFormatter.format(host: $0, protocol: .hypertext, useSSL: !$0.isLocal)
            },
            universeConfig: universeConfig,
            strategyIfUnsuitable: strategyIfUnsuitable
        )
    }
    
    func loadNodes() -> Observable<[Node]> {
        return Observable.combineLatest(urls.map { [unowned self] urlToNode in
            return self.infoOfNode(urlToNode).getInfo().map { try Node(nodeInfo: $0) }
        }) { $0 }
    }
    
    var configOfNode: (Node) -> Observable<UniverseConfig> {
        return { RESTClientsRetainer.restClient(node: $0).getUniverseConfig() }
    }
}

private extension NodeDiscoveryHardCoded {
    var infoOfNode: (FormattedURL) -> NodeInfoRequesting {
        return { RESTClientsRetainer.restClient(urlToNode: $0) }
    }
    
//    var universeConfigRequester: UniverseConfigRequesting {
//        implementMe()
//    }
}

