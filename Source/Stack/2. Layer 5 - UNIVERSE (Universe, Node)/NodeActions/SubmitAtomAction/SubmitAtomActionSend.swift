//
//  SubmitAtomActionSend.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-08-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

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
