//
//  SubmitAtomAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol SubmitAtomAction: NodeAction {
    /// The unique id representing a fetch atoms flow. That is, each type of action in a single flow instance
    /// must have the same unique id.
    var uuui: UUID { get }
    
    /// The atom to submit
    var atom: Atom { get }
}
