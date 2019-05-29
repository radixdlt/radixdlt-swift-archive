//
//  Shards.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon
/// Represents an interval of Radix shards
public struct ShardInterval:
    RadixCodable,
    RangeExpression,
    Equatable,
    Hashable,
    Codable {
// swiftlint:enable colon
    public typealias Bound = Shard
    
    private let range: Range<Bound>
    
    public init(range: Range<Bound>) {
        self.range = range
    }
}

public extension ShardInterval {
    enum Error: Swift.Error {
        case upperMustBeGreaterThanLower
    }
    
    init(lower: Bound, upper: Bound) throws {
        guard lower < upper else {
            throw Error.upperMustBeGreaterThanLower
        }
        let actuallyCheckedbounds = (lower, upper)
        self.init(range: Range(uncheckedBounds: actuallyCheckedbounds))
    }
}

// MARK: - RangeExpression
public extension ShardInterval {
    func relative<C>(to collection: C) -> Range<Shard> where C: Collection, ShardInterval.Bound == C.Index {
        return range.relative(to: collection)
    }
    
    func contains(_ element: Shard) -> Bool {
        return range.contains(element)
    }
}

// MARK: - Codable
public extension ShardInterval {
    
    enum CodingKeys: String, CodingKey {
        case low
        case high
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lower = try container.decode(Shard.self, forKey: .low)
        let upper = try container.decode(Shard.self, forKey: .high)
        try self.init(lower: lower, upper: upper)
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<ShardInterval.CodingKeys>] {
        return [
            EncodableKeyValue(key: .low, value: range.lowerBound),
            EncodableKeyValue(key: .high, value: range.upperBound)
        ]
    }
}
