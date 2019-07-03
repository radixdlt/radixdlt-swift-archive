////
////  StrategyWhenNodeIsUnsuitable.swift
////  RadixSDK iOS
////
////  Created by Alexander Cyon on 2019-07-02.
////  Copyright © 2019 Radix DLT. All rights reserved.
////
//
//import Foundation
//
//public struct StrategyWhenNodeIsUnsuitable {
//    let ifOffline: StrategyWhenNodeIsOffline
//    let ifDontServeShard: StrategyWhenNodeDoesNotServeshard
//    let ifUniverseMismatch: StrategyWhenNodeIsInTheWrongUniverse
//    
//    public init(
//        ifOffline: StrategyWhenNodeIsOffline = .default,
//        ifShardMismatch: StrategyWhenNodeDoesNotServeshard = .default,
//        ifUniverseMismatch: StrategyWhenNodeIsInTheWrongUniverse = .default
//        ) {
//        self.ifOffline = ifOffline
//        self.ifDontServeShard = ifShardMismatch
//        self.ifUniverseMismatch = ifUniverseMismatch
//    }
//}
//
//public extension StrategyWhenNodeIsUnsuitable {
//    
//    var shouldThrowWhenOffline: Bool {
//        switch ifOffline {
//        case .throwError: return true
//        case .fallbackToAnySuitableNode, .pollAndReconnectWhenOnline: return false
//        }
//    }
//    
//    var shouldThrowWhenUniverseMismatch: Bool {
//        switch ifUniverseMismatch {
//        case .throwError: return true
//        case .fallbackToAnySuitableNode: return false
//        }
//    }
//    
//    var shouldThrowWhenShardMismatch: Bool {
//        switch ifDontServeShard {
//        case .throwError: return true
//        case .fallbackToAnySuitableNode: return false
//        }
//    }
//}
//
//public extension StrategyWhenNodeIsUnsuitable {
//    enum StrategyWhenNodeIsOffline {
//        case throwError
//        case fallbackToAnySuitableNode
//        case pollAndReconnectWhenOnline
//    }
//}
//
//public extension StrategyWhenNodeIsUnsuitable {
//    enum StrategyWhenNodeDoesNotServeshard {
//        case throwError
//        case fallbackToAnySuitableNode
//    }
//}
//
//public extension StrategyWhenNodeIsUnsuitable {
//    enum StrategyWhenNodeIsInTheWrongUniverse {
//        case throwError
//        case fallbackToAnySuitableNode
//    }
//}
//
//// MARK: - Presets
//public extension StrategyWhenNodeIsUnsuitable {
//    static let `default`: StrategyWhenNodeIsUnsuitable = .fallbackToAnySuitableNode
//    
//    static var fallbackToAnySuitableNode: StrategyWhenNodeIsUnsuitable {
//        return StrategyWhenNodeIsUnsuitable(ifOffline: .fallbackToAnySuitableNode, ifShardMismatch: .fallbackToAnySuitableNode, ifUniverseMismatch: .fallbackToAnySuitableNode)
//    }
//    
//    static var throwError: StrategyWhenNodeIsUnsuitable {
//        return StrategyWhenNodeIsUnsuitable(ifOffline: .throwError, ifShardMismatch: .throwError, ifUniverseMismatch: .throwError)
//    }
//}
//
//public extension StrategyWhenNodeIsUnsuitable.StrategyWhenNodeIsOffline {
//    static var `default`: StrategyWhenNodeIsUnsuitable.StrategyWhenNodeIsOffline {
//        return .fallbackToAnySuitableNode
//    }
//}
//
//public extension StrategyWhenNodeIsUnsuitable.StrategyWhenNodeDoesNotServeshard {
//    static var `default`: StrategyWhenNodeIsUnsuitable.StrategyWhenNodeDoesNotServeshard {
//        return .fallbackToAnySuitableNode
//    }
//}
//
//public extension StrategyWhenNodeIsUnsuitable.StrategyWhenNodeIsInTheWrongUniverse {
//    static var `default`: StrategyWhenNodeIsUnsuitable.StrategyWhenNodeIsInTheWrongUniverse {
//        return .fallbackToAnySuitableNode
//    }
//}
