//
//  Shards.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias Shard = Int64
public struct Shards: RangeExpression, Codable {
    public typealias Bound = Shard
    
    private let range: Range<Bound>
    
    public init(lower: Bound, upper: Bound) {
        self.range = Range(uncheckedBounds: (lower: lower, upper: upper))
    }
}

// MARK: - RangeExpression
public extension Shards {
    func relative<C>(to collection: C) -> Range<Shard> where C: Collection, Shards.Bound == C.Index {
        return range.relative(to: collection)
    }
    
    func contains(_ element: Shard) -> Bool {
        return range.contains(element)
    }
}

// MARK: - Codable
public extension Shards {
    
    public enum CodingKeys: String, CodingKey {
        case low
        case high
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lower = try container.decode(Shard.self, forKey: .low)
        let upper = try container.decode(Shard.self, forKey: .high)
        self.init(lower: lower, upper: upper)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(range.lowerBound, forKey: .low)
        try container.encode(range.upperBound, forKey: .high)
    }
}
