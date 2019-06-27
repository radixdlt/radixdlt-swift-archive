//
//  NodeFindingStrategy.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct NodeFindingg {
    public let connectToNodeMethod: ConnectToNodeMethod
    public let config: UniverseConfig
    public let discovery: SuitableNodeDiscovering
    public let strategyWhenAllNodesAreUnsuitable: StrategyWhenNodeIsUnsuitable
    
    private init(
        connectToNodeMethod: ConnectToNodeMethod,
        config: UniverseConfig,
        discovery: SuitableNodeDiscovering,
        strategyWhenAllNodesAreUnsuitable: StrategyWhenNodeIsUnsuitable
    ) {
        self.connectToNodeMethod = connectToNodeMethod
        self.config = config
        self.discovery = discovery
        self.strategyWhenAllNodesAreUnsuitable = strategyWhenAllNodesAreUnsuitable
    }
}

public extension NodeFindingg {
    static func anySuitableNode(
        config: UniverseConfig,
        discovery: SuitableNodeDiscovering,
        selection: NodeSelection = .random
    ) -> NodeFindingg {
        
        return NodeFindingg(
            connectToNodeMethod: .anySuitableNode(selection: selection),
            config: config,
            discovery: discovery,
            strategyWhenAllNodesAreUnsuitable: .throwError
        )
        
    }
    
    static func connectToSpecificNode(
        url: (FormattedURL),
        config: UniverseConfig,
        strategyForWhenNodeIsInsuitable: StrategyWhenNodeIsUnsuitable = .default
    ) -> NodeFindingg {
        
        let discovery = NodeDiscoveryHardCoded(
            formattedURLs: [url],
            universeConfig: config,
            strategyIfUnsuitable: strategyForWhenNodeIsInsuitable
        )
        
        return NodeFindingg(
            connectToNodeMethod: .connectToSpecificNode(url, ifUnsuitable: strategyForWhenNodeIsInsuitable),
            config: config,
            discovery: discovery,
            strategyWhenAllNodesAreUnsuitable: strategyForWhenNodeIsInsuitable
        )
        
    }
}

public enum ConnectToNodeMethod {
    case anySuitableNode(selection: NodeSelection)
    case connectToSpecificNode(FormattedURL, ifUnsuitable: StrategyWhenNodeIsUnsuitable)
    
}

public enum NodeFindingStrategy {
    case anySuitableNode(
        discovery: SuitableNodeDiscovering,
        universeConfig: UniverseConfig,
        selection: NodeSelection,
        ifSpecifiedNodeIsUnsuitable: StrategyWhenNodeIsUnsuitable
    )
    
    case connectToSpecificNode(
        urlToNode: FormattedURL,
        universeConfig: UniverseConfig,
        ifSpecifiedNodeIsUnsuitable: StrategyWhenNodeIsUnsuitable
    )
}

public extension NodeFindingStrategy {
    var discovery: SuitableNodeDiscovering {
        switch self {
        case .anySuitableNode(let discovery, _, _, _): return discovery
        case .connectToSpecificNode(let url, let universeConfig, let nodeFindingStrategy):
            return NodeDiscoveryHardCoded(
                formattedURLs: [url],
                universeConfig: universeConfig,
                strategyIfUnsuitable: nodeFindingStrategy
            )
        }
    }
    
    var config: UniverseConfig {
        switch self {
        case .anySuitableNode(_, let universeConfig, _, _):
            return universeConfig
        case .connectToSpecificNode(_, let universeConfig, _):
            return universeConfig
        }
    }
    
    var ifSpecifiedNodeIsUnsuitable: StrategyWhenNodeIsUnsuitable {
        switch self {
        case .anySuitableNode(_, _, _, let ifSpecifiedNodeIsUnsuitable): return ifSpecifiedNodeIsUnsuitable
        case .connectToSpecificNode(_, _, let ifSpecifiedNodeIsUnsuitable):
            return ifSpecifiedNodeIsUnsuitable
        }
    }
}

public enum NodeSelection {
    case random
}

public struct StrategyWhenNodeIsUnsuitable {
    let ifOffline: StrategyWhenNodeIsOffline
    let ifDontServeShard: StrategyWhenNodeDoesNotServeshard
    let ifUniverseMismatch: StrategyWhenNodeIsInTheWrongUniverse
    
    public init(
        ifOffline: StrategyWhenNodeIsOffline = .default,
        ifShardMismatch: StrategyWhenNodeDoesNotServeshard = .default,
        ifUniverseMismatch: StrategyWhenNodeIsInTheWrongUniverse = .default
    ) {
        self.ifOffline = ifOffline
        self.ifDontServeShard = ifShardMismatch
        self.ifUniverseMismatch = ifUniverseMismatch
    }
}

public extension StrategyWhenNodeIsUnsuitable {
    
    var shouldThrowWhenOffline: Bool {
        switch ifOffline {
        case .throwError: return true
        case .fallbackToAnySuitableNode, .pollAndReconnectWhenOnline: return false
        }
    }
    
    var shouldThrowWhenUniverseMismatch: Bool {
        switch ifUniverseMismatch {
        case .throwError: return true
        case .fallbackToAnySuitableNode: return false
        }
    }
    
    var shouldThrowWhenShardMismatch: Bool {
        switch ifDontServeShard {
        case .throwError: return true
        case .fallbackToAnySuitableNode: return false
        }
    }
}

public extension StrategyWhenNodeIsUnsuitable {
    enum StrategyWhenNodeIsOffline {
        case throwError
        case fallbackToAnySuitableNode
        case pollAndReconnectWhenOnline
    }
}

public extension StrategyWhenNodeIsUnsuitable {
    enum StrategyWhenNodeDoesNotServeshard {
        case throwError
        case fallbackToAnySuitableNode
    }
}

public extension StrategyWhenNodeIsUnsuitable {
    enum StrategyWhenNodeIsInTheWrongUniverse {
        case throwError
        case fallbackToAnySuitableNode
    }
}

// MARK: - Presets
public extension StrategyWhenNodeIsUnsuitable {
    static let `default`: StrategyWhenNodeIsUnsuitable = .fallbackToAnySuitableNode
    
    static var fallbackToAnySuitableNode: StrategyWhenNodeIsUnsuitable {
        return StrategyWhenNodeIsUnsuitable(ifOffline: .fallbackToAnySuitableNode, ifShardMismatch: .fallbackToAnySuitableNode, ifUniverseMismatch: .fallbackToAnySuitableNode)
    }
    
    static var throwError: StrategyWhenNodeIsUnsuitable {
        return StrategyWhenNodeIsUnsuitable(ifOffline: .throwError, ifShardMismatch: .throwError, ifUniverseMismatch: .throwError)
    }
}

public extension StrategyWhenNodeIsUnsuitable.StrategyWhenNodeIsOffline {
    static var `default`: StrategyWhenNodeIsUnsuitable.StrategyWhenNodeIsOffline {
        return .fallbackToAnySuitableNode
    }
}

public extension StrategyWhenNodeIsUnsuitable.StrategyWhenNodeDoesNotServeshard {
    static var `default`: StrategyWhenNodeIsUnsuitable.StrategyWhenNodeDoesNotServeshard {
        return .fallbackToAnySuitableNode
    }
}

public extension StrategyWhenNodeIsUnsuitable.StrategyWhenNodeIsInTheWrongUniverse {
    static var `default`: StrategyWhenNodeIsUnsuitable.StrategyWhenNodeIsInTheWrongUniverse {
        return .fallbackToAnySuitableNode
    }
}
