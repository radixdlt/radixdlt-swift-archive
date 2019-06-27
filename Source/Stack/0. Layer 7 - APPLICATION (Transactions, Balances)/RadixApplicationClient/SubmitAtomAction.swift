//
//  SubmitAtomAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum SubmitAtomAction: NodeAction {
    public typealias Submission = (uuid: UUID, atom: Atom)
    
    /// Step 1
    case request(Submission, completeOnAtomStoredOnly: Bool)
    
    /// Step 2
    case sendTo(Submission, toNode: Node, completeOnAtomStoredOnly: Bool)
    
    case statusOf(Submission, sentToNode: Node, statusNotification: AtomStatusNotification)
    
    /// Step 4
    case received(Submission, byNode: Node)
    
    /// Step 5
    case completed(Submission, fromNode: Node, result: Result<Data, SubmitAtomError>)
}

public extension SubmitAtomAction {
    var node: Node? {
        switch self {
        case .request:
            // No node assigned yet
            return nil
        case .sendTo(_, let toNode, _): return toNode
        case .statusOf(_, let sentToNode, _): return sentToNode
        case .received(_, let byNode): return byNode
        case .completed(_, let fromNode, _): return fromNode
        }
    }
    
    var submission: Submission {
        switch self {
        case .request(let submission, _): return submission
        case .sendTo(let submission, _, _): return submission
        case .statusOf(let submission, _, _): return submission
        case .received(let submission, _): return submission
        case .completed(let submission, _, _): return submission
        }
    }
    
    var uuid: UUID {
        return submission.uuid
    }
    
    var isCompleted: Bool {
        guard case .completed = self else { return false }
        return true
    }
    
    var isStatusUpdate: Bool {
        guard case .statusOf = self else { return false }
        return true
    }
}

public extension SubmitAtomAction {
    
    static func newRequest(atom: Atom, completeOnAtomStoredOnly: Bool) -> SubmitAtomAction {
        
        return SubmitAtomAction.request(
            (UUID(), atom),
            completeOnAtomStoredOnly: completeOnAtomStoredOnly
        )
    }
    
    static func toSpecificNode(_ node: Node, atom: Atom, completeOnAtomStoredOnly: Bool) -> SubmitAtomAction {
        return SubmitAtomAction.sendTo(
            (UUID(), atom),
            toNode: node,
            completeOnAtomStoredOnly: completeOnAtomStoredOnly
        )
    }
    
}
