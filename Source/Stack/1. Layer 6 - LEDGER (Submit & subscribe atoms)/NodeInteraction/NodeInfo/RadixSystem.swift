//
//  RadixSystem.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

public struct RadixSystem:
    RadixModelTypeStaticSpecifying,
    Codable,
    Equatable,
    Hashable {
    // swiftlint:enable colon
    
    public static let serializer = RadixModelType.radixSystem
    
    public let shards: ShardInterval
    
    public init(
        shards: ShardInterval
    ) {
        self.shards = shards
    }
}

public extension RadixSystem {
    
    init(lowerShard: Shard, upperShard: Shard) throws {
        let shards = try ShardInterval(lower: lowerShard, upper: upperShard)
        self.init(shards: shards)
    }
}
