//
//  SubmitAtomAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol SubmitAtomAction: NodeAction {
    var atom: SignedAtom { get }
    var uuid: UUID { get }
}

public extension SubmitAtomAction {
    var isCompleted: Bool {
        return self is SubmitAtomActionCompleted
    }
    
    var isStatusUpdate: Bool {
        return self is SubmitAtomActionStatus
    }
}

public struct SubmitAtomActionCompleted: SubmitAtomAction {
    public let atom: SignedAtom
    public let node: Node
    public let uuid: UUID
    private init(
        atom: SignedAtom,
        node: Node,
        uuid: UUID
    ) {
        self.atom = atom
        self.node = node
        self.uuid = uuid
    }
    
    public init(sendAction: SubmitAtomActionSend, node: Node) {
        self.init(atom: sendAction.atom, node: node, uuid: sendAction.uuid)
    }
}

public struct SubmitAtomActionRequest: SubmitAtomAction, FindANodeRequestAction {
    public let atom: SignedAtom
    public let isCompletingOnStoreOnly: Bool
    public let uuid: UUID
    
    public init(atom: SignedAtom, isCompletingOnStoreOnly: Bool, uuid: UUID = .init()) {
        self.atom = atom
        self.isCompletingOnStoreOnly = isCompletingOnStoreOnly
        self.uuid = uuid
    }
}

public struct SubmitAtomActionSend: SubmitAtomAction {
    public let atom: SignedAtom
    public let node: Node
    public let isCompletingOnStoreOnly: Bool
    public let uuid: UUID
    
    public init(atom: SignedAtom, node: Node, isCompletingOnStoreOnly: Bool, uuid: UUID = .init()) {
        self.atom = atom
        self.node = node
        self.isCompletingOnStoreOnly = isCompletingOnStoreOnly
        self.uuid = uuid
    }
    
    public init(request: SubmitAtomActionRequest, node: Node) {
        self.init(atom: request.atom, node: node, isCompletingOnStoreOnly: request.isCompletingOnStoreOnly)
    }
}

public struct SubmitAtomActionRecived: SubmitAtomAction {
    public let atom: SignedAtom
    public let node: Node
    public let uuid: UUID
    
    private init(atom: SignedAtom, node: Node, uuid: UUID) {
        self.atom = atom
        self.node = node
        self.uuid = uuid
    }
    
    public init(sendAction: SubmitAtomActionSend, node: Node) {
        self.init(atom: sendAction.atom, node: node, uuid: sendAction.uuid)
    }
}

public struct SubmitAtomActionStatus: SubmitAtomAction {
    public let atom: SignedAtom
    public let node: Node
    public let statusNotification: AtomStatusNotification
    public let uuid: UUID
    
    private init(atom: SignedAtom, node: Node, statusNotification: AtomStatusNotification, uuid: UUID) {
        self.atom = atom
        self.node = node
        self.statusNotification = statusNotification
        self.uuid = uuid
    }
    
    public init(sendAction: SubmitAtomActionSend, node: Node, statusNotification: AtomStatusNotification) {
        self.init(atom: sendAction.atom, node: node, statusNotification: statusNotification, uuid: sendAction.uuid)
    }
}

//public enum SubmitAtomAction: NodeAction {
//    public typealias Submission = (uuid: UUID, atom: SignedAtom)
//
//    /// Step 1
//    case request(Submission, completeOnAtomStoredOnly: Bool)
//
//    /// Step 2
//    case sendTo(Submission, toNode: Node, completeOnAtomStoredOnly: Bool)
//
//    case statusOf(Submission, sentToNode: Node, statusNotification: SignedAtomStatusNotification)
//
//    /// Step 4
//    case received(Submission, byNode: Node)
//
//    /// Step 5
//    case completed(Submission, fromNode: Node, result: Result<Data, SubmitAtomError>)
//}
//
//public extension SubmitAtomAction {
//    var node: Node? {
//        switch self {
//        case .request:
//            // No node assigned yet
//            return nil
//        case .sendTo(_, let toNode, _): return toNode
//        case .statusOf(_, let sentToNode, _): return sentToNode
//        case .received(_, let byNode): return byNode
//        case .completed(_, let fromNode, _): return fromNode
//        }
//    }
//
//    var submission: Submission {
//        switch self {
//        case .request(let submission, _): return submission
//        case .sendTo(let submission, _, _): return submission
//        case .statusOf(let submission, _, _): return submission
//        case .received(let submission, _): return submission
//        case .completed(let submission, _, _): return submission
//        }
//    }
//
//    var uuid: UUID {
//        return submission.uuid
//    }
//
//    var isCompleted: Bool {
//        guard case .completed = self else { return false }
//        return true
//    }
//
//    var isStatusUpdate: Bool {
//        guard case .statusOf = self else { return false }
//        return true
//    }
//}
//
//public extension SubmitAtomAction {
//
//    static func newRequest(atom: SignedAtom, completeOnAtomStoredOnly: Bool) -> SubmitAtomAction {
//
//        return SubmitAtomAction.request(
//            (UUID(), atom),
//            completeOnAtomStoredOnly: completeOnAtomStoredOnly
//        )
//    }
//
//    static func toSpecificNode(_ node: Node, atom: SignedAtom, completeOnAtomStoredOnly: Bool) -> SubmitAtomAction {
//        return SubmitAtomAction.sendTo(
//            (UUID(), atom),
//            toNode: node,
//            completeOnAtomStoredOnly: completeOnAtomStoredOnly
//        )
//    }
//
//}
