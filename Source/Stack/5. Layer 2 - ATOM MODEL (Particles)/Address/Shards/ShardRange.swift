//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    
    internal let range: Range<Bound>
    
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
    
    /// From `lower` (inclusive) to `upper` (exclusive).
    init(lower: Bound, upperExclusive: Bound) throws {
        guard lower < upperExclusive else {
            throw Error.upperMustBeGreaterThanLower
        }
        let actuallyCheckedbounds = (lower, upperExclusive)
        self.init(range: Range(uncheckedBounds: actuallyCheckedbounds))
    }
    
    /// From `lower` (inclusive) to `upper` (inclusive).
    init(lower: Bound, upperInclusive upperExclusive: Bound) throws {
        // We are making the `upperExclusive` init inclusive, by adding 1.
        try self.init(lower: lower, upperExclusive: upperExclusive + 1)
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
        try self.init(lower: lower, upperInclusive: upper)
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .low, value: range.lowerBound),
            EncodableKeyValue(key: .high, value: range.upperBound)
        ]
    }
}
