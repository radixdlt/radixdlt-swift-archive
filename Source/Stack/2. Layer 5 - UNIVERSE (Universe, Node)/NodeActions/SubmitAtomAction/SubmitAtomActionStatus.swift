//
//  SubmitAtomActionStatus.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-08-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SubmitAtomActionStatus: SubmitAtomAction {
    public let atom: SignedAtom
    public let node: Node
    public let statusEvent: AtomStatusEvent
    public let uuid: UUID
    
    private init(atom: SignedAtom, node: Node, statusEvent: AtomStatusEvent, uuid: UUID) {
        self.atom = atom
        self.node = node
        self.statusEvent = statusEvent
        self.uuid = uuid
    }
    
    public init(sendAction: SubmitAtomActionSend, node: Node, statusEvent: AtomStatusEvent) {
        self.init(atom: sendAction.atom, node: node, statusEvent: statusEvent, uuid: sendAction.uuid)
    }
}

public extension SubmitAtomActionStatus {
    var debugDescription: String {
        return """
        \(type(of: self))(status: \(statusEvent), atomWithAid: \(atom.shortAid), node: \(node), uuid: \(uuid.uuidString.suffix(4)))
        """
    }
}
