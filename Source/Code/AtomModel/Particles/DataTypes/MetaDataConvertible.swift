//
//  MetaDataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// Shared protocol for MetaData and ChronoMetaData, some dictionary having `MetaDataKey` as key.
public protocol MetaDataConvertible:
    DictionaryCodable,
    CBORDictionaryConvertible,
    Equatable
where
    Key == MetaDataKey,
    Value == String {}

// swiftlint:enable colon

public extension MetaDataConvertible {
    var timestampString: String {
        guard let timestampString = self[.timestamp] else {
            incorrectImplementation("MetaData must contain timestamp")
        }
        return timestampString
    }
    
    var timestamp: Date {
        guard let timestamp = TimeConverter.dateFrom(string: timestampString) else {
            incorrectImplementation("Should not be possible to save bad timestamp string")
        }
        return timestamp
    }
    
    static func timestamp(_ date: Date) -> Self {
        return [.timestamp: TimeConverter.stringFrom(date: date)]
    }
    
    static var timeNow: Self {
        return .timestamp(Date())
    }
}
