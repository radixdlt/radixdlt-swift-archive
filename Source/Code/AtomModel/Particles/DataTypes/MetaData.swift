//
//  MetaData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct MetaData: MetaDataConvertible {
    public typealias Key = MetaDataKey
    public typealias Value = String
    public let dictionary: [Key: Value]
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
}

public struct ChronoMetaData: MetaDataConvertible {
    public typealias Key = MetaDataKey
    public typealias Value = String
    public let dictionary: [Key: Value]
    
    public init(validate unvalidated: Map) throws {
        let validated = try ChronoMetaData.validate(unvalidated)
        self.dictionary = validated
    }
    
    public init(dictionary unvalidated: Map) {
        do {
            let validated = try ChronoMetaData.validate(unvalidated)
            self.dictionary = validated
        } catch {
            incorrectImplementation("Invalid Map, error: \(error)")
        }
    }
    
    public enum Error: Swift.Error {
        case noTimestampString
        case invalidTimestampString
    }
    
    static func validate(_ map: Map) throws -> Map {
        guard let timestampString = map[.timestamp] else {
            throw Error.noTimestampString
        }
        guard TimeConverter.dateFrom(string: timestampString) != nil else {
            throw Error.invalidTimestampString
        }
        return map
    }
}

extension Date: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        guard let date = TimeConverter.dateFrom(string: value) else {
            incorrectImplementation("invalid date string: '\(value)'")
        }
        self = date
    }
}

public final class TimeConverter {
    
    static func stringFrom(date: Date) -> String {
        let seconds = date.timeIntervalSince1970
        let milliseconds = seconds * 1000
        
        // UInt64.max = 18446744073709, which will not overflow until
        // the year of 2554 (21 July), so it feels like a reasonable
        // technical debt.
        return UInt64(milliseconds).description
    }
    
    static func dateFrom(string: String) -> Date? {
        guard let millisecondsSince1970 = TimeInterval(string) else {
            return nil
        }
        return dateFrom(millisecondsSince1970: millisecondsSince1970)
    }
    
    static func dateFrom(millisecondsSince1970: TimeInterval) -> Date {
        let secondsSince1970 = millisecondsSince1970 / 1000
        return Date(timeIntervalSince1970: secondsSince1970)
    }
}

public protocol KeyValued: ExpressibleByDictionaryLiteral where Key: Hashable {
    var keys: Dictionary<Key, Value>.Keys { get }
    var values: Dictionary<Key, Value>.Values { get }
}

extension Dictionary: KeyValued {}

extension KeyValued where Key == MetaDataKey {
    var containsTimestamp: Bool {
        return keys.contains(.timestamp)
    }
}
