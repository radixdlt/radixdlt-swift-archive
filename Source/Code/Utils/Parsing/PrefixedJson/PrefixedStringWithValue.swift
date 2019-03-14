//
//  PrefixedJson.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct PrefixedStringWithValue: Decodable, StringRepresentable {
    public let stringValue: String
    public let jsonPrefix: JSONPrefix
    
    // swiftlint:disable:next function_body_length
    public init(string: String) throws {
        var prefix: JSONPrefix?
        for jsonPrefix in JSONPrefix.allCases {
            guard string.contains(jsonPrefix.identifier) else { continue }
            prefix = jsonPrefix
            break
        }
        guard let jsonPrefix = prefix, let range = string.range(of: jsonPrefix.identifier) else {
            throw Error.noPrefixFound
        }
        guard range.lowerBound == string.startIndex else {
            throw Error.noPrefixFoundAtStart
        }
        let value = string.removingSubrange(range)
        guard !value.isEmpty else {
            throw Error.noValueFound
        }
        self.jsonPrefix = jsonPrefix
        self.stringValue = value
    }
    
    public init(value: String, prefix: JSONPrefix) {
        self.stringValue = value
        self.jsonPrefix = prefix
    }
}

public extension PrefixedStringWithValue {
    var identifer: String {
        return [
            jsonPrefix.identifier,
            String(describing: stringValue)
        ].joined()
    }
}

// MARK: - Error
public extension PrefixedStringWithValue {
    public enum Error: Swift.Error {
        case noPrefixFoundAtStart
        case noPrefixFound
        case noValueFound
        case prefixMismatch(expected: JSONPrefix, butGot: JSONPrefix)

    }
}

// MARK: - Decodable
public extension PrefixedStringWithValue {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        try self.init(string: rawString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifer)
    }
}

// MARK: - CustomStringConvertible
public extension PrefixedStringWithValue {
    var description: String {
        return identifer
    }
}
