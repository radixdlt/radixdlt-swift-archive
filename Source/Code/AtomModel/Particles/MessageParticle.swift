//
//  MessageParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct MessageParticle: ParticleConvertible {
    
    private let from: Address
    
    // MARK: ParticleConvertible properties
    public let quarks: Quarks
}
