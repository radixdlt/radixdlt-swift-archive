//
//  Ledger.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol Ledger {
    var atomPuller: AtomPuller { get }
    var atomSubmitter: AtomSubmitter { get }
    
    var particleStore: ParticleStore { get }
    var atomStore: AtomStore { get }
}
