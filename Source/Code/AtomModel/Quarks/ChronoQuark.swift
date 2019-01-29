//
//  ChronoQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct ChronoQuark: QuarkConvertible, ExpressibleByDictionaryLiteral, Collection {
    public typealias Key = Timestamp
    public typealias Value = Date
    public let timestamps: [Key: Value]
    
    public init(timestamps: [Key: Value] = [:]) {
        self.timestamps = timestamps
    }
}

// MARK: - ExpressibleByDictionaryLiteral
public extension ChronoQuark {
    init(dictionaryLiteral timestamps: (Key, Value)...) {
        self.init(timestamps: Dictionary(uniqueKeysWithValues: timestamps))
    }
}

// MARK: - Convenience Init
public extension ChronoQuark {
    init(timestamp: Timestamp = .default, date: Date) {
        self.timestamps = [timestamp: date]
    }
}

public extension ChronoQuark {
    subscript(key: Key) -> Value? {
        return timestamps[key]
    }
}

// MARK: - Collection
public extension ChronoQuark {
    typealias Element = Dictionary<Key, Value>.Element
    typealias Index = Dictionary<Key, Value>.Index
    var startIndex: Index {
        return timestamps.startIndex
    }
    var endIndex: Index {
        return timestamps.endIndex
    }
    subscript(position: Index) -> Element {
        return timestamps[position]
    }
    func index(after index: Index) -> Index {
        return timestamps.index(after: index)
    }
}

// MARK: Codable
public extension ChronoQuark {
    
    public enum CodingKeys: String, CodingKey {
        case timestamps
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Remember `decoder.dateDecodingStrategy = .millisecondsSince1970`
        let stringDateMap = try container.decode([String: Date].self, forKey: .timestamps)
        let timestamps = [Key: Value](uniqueKeysWithValues: try stringDateMap.map {
            (
                try Timestamp(string: $0.key),
                $0.value
            )
        })
        self.init(timestamps: timestamps)
    }
}

// MARK: - Public
public extension ChronoQuark {
    
    func time(for timestamp: Timestamp) -> Date? {
        return timestamps[timestamp]
    }
    
    var defaultTimestamp: Date? {
        return time(for: .default)
    }
}
