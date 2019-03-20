//
//  ChronoMetaData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// A MetaData type that enforces the occurence of one key-value pair for `timestamp`
public struct ChronoMetaData:
    MetaDataConvertible,
    ValueValidating {
// swiftlint:enable colon
    
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
}

// MARK: Validation
public extension ChronoMetaData {
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
