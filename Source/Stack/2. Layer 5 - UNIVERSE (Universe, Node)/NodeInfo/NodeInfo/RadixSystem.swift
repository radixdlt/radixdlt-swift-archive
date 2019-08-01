//
//  RadixSystem.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct RadixSystem:
    RadixModelTypeStaticSpecifying,
    Codable,
    Equatable,
    Hashable
{

    // swiftlint:enable colon opening_brace
    
    public static let serializer = RadixModelType.radixSystem
    
    public let shardSpace: ShardSpace
    
    public init(
        shardSpace: ShardSpace
    ) {
        self.shardSpace = shardSpace
    }
}

public extension RadixSystem {
    enum CodingKeys: String, CodingKey {
        case shardSpace = "shards"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let shardSpace = try container.decode(ShardSpace.self, forKey: .shardSpace)
        self.init(shardSpace: shardSpace)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(shardSpace, forKey: .shardSpace)
    }
}
