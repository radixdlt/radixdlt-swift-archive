//
//  SubmitAtomActionCompleted.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-08-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

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
