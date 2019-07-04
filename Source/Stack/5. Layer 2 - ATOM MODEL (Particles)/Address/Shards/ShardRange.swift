//
//  Shards.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// Represents an interval of Radix shards
public struct ShardRange:
    RadixCodable,
    RangeExpression,
    Equatable,
    Hashable,
    Codable,
    CustomStringConvertible
{

    // swiftlint:enable colon opening_brace
    
    public typealias Bound = Shard
    
    private let range: Range<Bound>
    
    public init(range: Range<Bound>) {
        self.range = range
    }
}

// MARK: - CustomStringConvertible
public extension ShardRange {
    var description: String {
        return "(\(range.lowerBound), \(range.upperBound))"
    }
}

// MARK: - Public
public extension ShardRange {
    var stride: Bound {
        return range.stride
    }
}

// MARK: - Convenience Init
public extension ShardRange {
    
    init(lower: Bound, upper: Bound) throws {
        guard lower < upper else {
            print("🧨 bad range: lower: \(lower), upper: \(upper)")
            throw Error.upperMustBeGreaterThanLower
        }
        let actuallyCheckedbounds = (lower, upper)
        self.init(range: Range(uncheckedBounds: actuallyCheckedbounds))
    }
}

// MARK: - Throwing
public extension ShardRange {
    enum Error: Swift.Error {
        case upperMustBeGreaterThanLower
    }
}

// MARK: - RangeExpression
public extension ShardRange {
    func relative<C>(to collection: C) -> Range<Shard> where C: Collection, ShardRange.Bound == C.Index {
        return range.relative(to: collection)
    }
    
    func contains(_ element: Shard) -> Bool {
        return range.contains(element)
    }
}

// MARK: - Codable
public extension ShardRange {
    
    enum CodingKeys: String, CodingKey {
        case serializer, version
        case low
        case high
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lower = try container.decode(Shard.self, forKey: .low)
        let upper = try container.decode(Shard.self, forKey: .high)
        try self.init(lower: lower, upper: upper)
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .low, value: range.lowerBound),
            EncodableKeyValue(key: .high, value: range.upperBound)
        ]
    }
}
