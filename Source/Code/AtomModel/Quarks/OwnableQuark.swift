//
//  OwnableQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct OwnableQuark: QuarkConvertible {
    public let owner: PublicKey
    public init(owner: PublicKey) {
        self.owner = owner
    }
}

// MARK: - Codable
public extension OwnableQuark {
    public enum CodingKeys: CodingKey {
        case owner
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.owner = try container.decode(Dson<PublicKey>.self, forKey: .owner).value
    }
}
