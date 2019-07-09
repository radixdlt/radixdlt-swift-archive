//
//  SubmitAtomAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol SubmitAtomAction: NodeAction, CustomDebugStringConvertible {
    var atom: SignedAtom { get }
    var uuid: UUID { get }
}

public extension SubmitAtomAction {
    var debugDescription: String {
        return """
        \(type(of: self))(atomWithAid: \(atom.identifier().hex.suffix(4)), node: \(node), uuid: \(uuid.uuidString.suffix(4)))
        """
    }
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
public extension SubmitAtomActionRequest {
    var shards: Shards {
        do {
            return try atom.requiredFirstShards()
        } catch { incorrectImplementation("should always be able to get shards") }
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
        self.init(
            atom: request.atom,
            node: node,
            isCompletingOnStoreOnly: request.isCompletingOnStoreOnly,
            uuid: request.uuid
        )
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
