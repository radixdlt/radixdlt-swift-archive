//
//  FungibleQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct FungibleQuark: QuarkConvertible {
    public let type: FungibleType
    public let planck: UInt64
    public let nonce: UInt64
    public let amount: Amount
}

// MARK: Codable
public extension FungibleQuark {
    public enum CodingKeys: CodingKey {
        case type, planck, nonce, amount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(Dson<StringDson<FungibleType>>.self, forKey: .type).value.value
        planck = try container.decode(UInt64.self, forKey: .planck)
        nonce = try container.decode(UInt64.self, forKey: .nonce)
        amount = try container.decode(Dson<Amount>.self, forKey: .amount).value
    }
}

// MARK: - Encodable
public extension FungibleQuark {
    func encode(to encoder: Encoder) throws {
        implementMe
    }
}

