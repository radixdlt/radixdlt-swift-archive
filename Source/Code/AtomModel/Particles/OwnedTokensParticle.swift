//
//  OwnedTokensParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BigInt

public struct OwnedTokensParticle: ParticleConvertible {
    public let tokenReference: ResourceIdentifier
    public let granularity: Granularity
    
    // MARK: ParticleConvertible properties
    public let quarks: Quarks
}

// MARK: Codable
public extension OwnedTokensParticle {
    public enum CodingKeys: String, CodingKey {
        case granularity, quarks
        case tokenReference = "token_reference"
    }
}

// MARK: Decodable
public extension OwnedTokensParticle {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quarks = try container.decode(Quarks.self, forKey: .quarks)
        tokenReference = try container.decode(Dson<ResourceIdentifier>.self, forKey: .tokenReference).value
        granularity = try container.decode(Dson<Granularity>.self, forKey: .granularity).value
     
    }
}

// MARK: Encodable
public extension OwnedTokensParticle {
    func encode(to encoder: Encoder) throws {
        implementMe
    }
}
