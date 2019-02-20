//
//  TokenParticle+Sequence.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Sequence where Element == TokenParticle {
    
    func filter(type: TokenType) -> [TokenParticle] {
        return filter { $0.type == type }
    }
}
