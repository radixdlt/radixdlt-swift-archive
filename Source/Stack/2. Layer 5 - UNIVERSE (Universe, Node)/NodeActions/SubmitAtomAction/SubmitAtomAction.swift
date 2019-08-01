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
        \(type(of: self))(atomWithAid: \(atom.shortAid), node: \(node), uuid: \(uuid.uuidString.suffix(4)))
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
