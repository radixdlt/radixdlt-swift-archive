//
//  Timestamp.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum Timestamp: String, StringInitializable, Hashable {
    case `default`
}

// MARK: - StringInitializable
public extension Timestamp {
    public init(string: String) throws {
        guard let timestamp = Timestamp(rawValue: string) else {
            throw Error.unsupportedTimestamp(string)
        }
        self = timestamp
    }
}

// MARK: - Error
public extension Timestamp {
    public enum Error: Swift.Error {
        case unsupportedTimestamp(String)
    }
}

// MARK: - CustomStringConvertible
public extension Timestamp {
    var description: String {
        return rawValue
    }
}
