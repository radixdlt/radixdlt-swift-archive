//
//  AtomUpdate.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// In Javascript see `RadixAtomUpdate` in Java see `AtomObservation`
public struct AtomUpdate {
    public let action: AtomEvent.AtomEventType
    public let atom: Atom
    public let isHead: Bool
}
