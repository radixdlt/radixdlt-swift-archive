//
//  RadixSystem.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct RadixSystem: Codable {
    private let shards: Shards
    public init(shards: Shards) {
        self.shards = shards
    }
}

public extension RadixSystem {
    
    public init(lowerShard: Shard, upperShard: Shard) throws {
        let shards = try Shards(lower: lowerShard, upper: upperShard)
        self.init(shards: shards)
    }
}
