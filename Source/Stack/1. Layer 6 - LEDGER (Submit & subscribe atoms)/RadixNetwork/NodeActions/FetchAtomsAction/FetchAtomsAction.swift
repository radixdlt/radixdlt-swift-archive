//
//  FetchAtomsAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum FetchAtomsAction: NodeAction {
    public typealias Submission = (uuid: UUID, address: Address)
    
    /// Step 1: Action which signals a new fetch atoms query request
    case request(Submission)
    
    /// Step 2: Action which represents a fetch atom query submitted to a specific node.
    case submitted(Submission, toNode: Node)

    /// Step 3: action which represents an atom observed event from a specific node for an atom fetch flow.
    case observation(Submission, fromNode: Node, observation: AtomObservation)
    
    /// Cancel action
    case cancel(Submission)
    
}

public extension FetchAtomsAction {
    var node: Node? {
        switch self {
        case .request:
            // No node assigned yet
            return nil
        case .submitted(_, let toNode): return toNode
        case .observation(_, let fromNode, _): return fromNode
        case .cancel: return nil
        }
    }
    
    var submission: Submission {
        switch self {
        case .request(let submission): return submission
        case .submitted(let submission, _): return submission
        case .observation(let submission, _, _): return submission
        case .cancel(let submission): return submission
        }
    }
}

public extension FetchAtomsAction {
    
    static func newRequest(address: Address) -> FetchAtomsAction {
        
        return FetchAtomsAction.request(
            (UUID.init(), address)
        )
    }
    
    static func cancel(action: FetchAtomsAction) -> FetchAtomsAction {
        return FetchAtomsAction.cancel(action.submission)
    }
}
