//
//  NodeFindingResult.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//enum NodeFindingResult {
//    public typealias FindingResult = Result<NodeInteraction, SpecificNode.UnsuitableReason>
//    
//    case anyNode(DefaultNodeInteraction)
//    case specificNode(SpecificNode)
//    
//    public enum SpecificNode {
//        case connectedToSpecifiedNode(DefaultNodeInteraction)
//        case didNotConnectToSpecifiedNodeFellbackTo(DefaultNodeInteraction, reason: UnsuitableReason)
//        case didNotConnectToSpecifiedNodeError(reason: UnsuitableReason)
//        
//        public enum UnsuitableReason: Swift.Error {
//            case offline, shardMismatch, wrongUniverse
//        }
//    }
//    
//    var result: FindingResult {
//        switch self {
//        case .anyNode(let nodeInteraction): return .success(nodeInteraction)
//        case .specificNode(let resultConnectingToSpecificNode):
//            switch resultConnectingToSpecificNode {
//            case .connectedToSpecifiedNode(let nodeInteraction): return .success(nodeInteraction)
//            case .didNotConnectToSpecifiedNodeFellbackTo(let fallbackNodeInteraction, _): return .success(fallbackNodeInteraction)
//            case .didNotConnectToSpecifiedNodeError(let reason): return .failure(reason)
//            }
//        }
//    }
//}
