//
//  ShardSpace.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct ShardSpace:
    RadixCodable,
    Throwing,
    CustomStringConvertible,
    Equatable,
    Hashable,
    Codable
{
    // swiftlint:enable colon opening_brace
    
    public static let serializer = RadixModelType.shardSpace
    
    public let range: ShardRange
    private let anchor: Shard /* not used? */
    
    public init(range: ShardRange, anchor: Shard) throws {
        if range.stride > ShardSpace.shardChunkRangeSpan {
            throw Error.spanOfRangeTooBig(expectedAtMost: ShardSpace.shardChunkRangeSpan, butGot: range.stride)
        }
        
        self.range = range
        self.anchor = anchor
    }
}

public extension ShardSpace {
    func intersectsWithShard(_ shard: Shard) -> Bool {
        let remainder = shard % ShardSpace.shardChunkRangeSpanHalf
        return range.contains(remainder)
    }
    
    func intersectsWithShards(_ shards: Shards) -> Bool {
        for shard in shards {
            guard intersectsWithShard(shard) else { continue }
            return true
        }
        return false
    }
}

// MARK: - CustomStringConvertible
public extension ShardSpace {
    var description: String {
        return """
        ShardSpace: \(range)
        """
    }
}

// MARK: - Throwing
public extension ShardSpace {
    enum Error: Swift.Error, Equatable {
        case spanOfRangeTooBig(expectedAtMost: Int64, butGot: Int64)
    }
}

// MARK: - Constants
public extension ShardSpace {
    static var numberOfShardChunks: Int64 = 1 << 20
    static var shardChunkRangeSpan = shardChunkRangeSpanHalf * 2
    static var shardChunkRangeSpanHalf: Int64 = -(Int64.min / numberOfShardChunks)
    static var shardChunkRange: ShardRange = {
        do {
            return try ShardRange(lower: -shardChunkRangeSpanHalf, upper: shardChunkRangeSpanHalf - 1)
        } catch {
            incorrectImplementation("Should always be able to create Shard Chunk Range")
        }
    }()
}

// MARK: - Codable
public extension ShardSpace {
    
    enum CodingKeys: String, CodingKey {
        case serializer, version
        case range
        case anchor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let range = try container.decode(ShardRange.self, forKey: .range)
        let anchor = try container.decode(Shard.self, forKey: .anchor)
        
        try self.init(range: range, anchor: anchor)
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .anchor, value: anchor),
            EncodableKeyValue(key: .range, value: range)
        ]
    }
}

