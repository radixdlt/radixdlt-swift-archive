//
//  ParticleTypes.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum ParticleTypes: String, Codable {
    case message
    case tokenDefinition
    case burnedToken
    case mintedToken
    case transferredToken
    case unique
}

public extension ParticleTypes {
    init(tokenType: TokenType) {
        switch tokenType {
        case .burned: self = .burnedToken
        case .minted: self = .mintedToken
        case .transferred: self = .transferredToken
        }
    }
}
