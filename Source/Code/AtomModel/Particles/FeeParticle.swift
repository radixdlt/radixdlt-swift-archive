//
//  FeeParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct FeeParticle: ParticleConvertible {
    
    public let service: EUID
    public let granularity: Granularity
    public let tokenReference: ResourceIdentifier
    
    // MARK: ParticleConvertible properties
    public let quarks: Quarks
}

// MARK: Codable
public extension FeeParticle {
    public enum CodingKeys: String, CodingKey {
        case granularity, quarks, service
        case tokenReference = "token_reference"
    }
}

// MARK: Decodable
public extension FeeParticle {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quarks = try container.decode(Quarks.self, forKey: .quarks)
        tokenReference = try container.decode(Dson<ResourceIdentifier>.self, forKey: .tokenReference).value
        granularity = try container.decode(Dson<Granularity>.self, forKey: .granularity).value
        service = try container.decode(Dson<EUID>.self, forKey: .service).value
    }
}

// MARK: Encodable
public extension FeeParticle {
    func encode(to encoder: Encoder) throws {
        implementMe
    }
}
