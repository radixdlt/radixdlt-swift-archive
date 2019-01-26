//
//  Dson.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Dson<Value: DsonConvertible>: Codable {
    public let value: Value
    public init(value: Value) {
        self.value = value
    }
}

extension Dson: Hashable where Value: Hashable {}
extension Dson: Equatable where Value: Equatable {}

// MARK: - Decodable
private let separator = ":"
public extension Dson {
    
    init(from: Value.From) throws {
        try self.init(value: Value(from: from))
    }
    
    init(tag: DsonTag, rawValueString: String) throws {
        try self.init(from: try Value.From(string: rawValueString))
    }
    
    // swiftlint:disable:next function_body_length
    init(string rawString: String) throws {
        let separatorCount = rawString.countInstances(of: separator)
        switch separatorCount {
        case 0: throw Error.noSeparator
        case 1: throw Error.singleSeparator
        default: break
        }
        guard rawString[0] == separator else {
            throw Error.noLeadingSepartor
        }
        let leadingStripped = String(rawString.dropFirst())
        
        var tagRaw = ""
        var valueString = ""
        for index in 0..<leadingStripped.count {
            guard leadingStripped[index] != separator else {
                tagRaw = String(leadingStripped.prefix(index))
                valueString = String(leadingStripped.dropFirst(index+1))
                break
            }
        }
        
        guard let tag = DsonTag(rawValue: tagRaw) else {
            throw Error.noTagFound
        }
        guard !valueString.isEmpty else {
            throw Error.noValueFound
        }
        try self.init(tag: tag, rawValueString: valueString)
    }
    public var identifer: String {
        return [
            separator,
//            Value.From.dsonTag.rawValue,
            separator,
            String(describing: value)
        ].joined()
    }

}

// MARK: - Error
public extension Dson {
    public enum Error: Swift.Error {
        case noSeparator
        case singleSeparator
        case noLeadingSepartor
        case noTagFound
        case noValueFound
        case valueMismatch
        case tagMismatch(expected: DsonTag, butGot: DsonTag)
    }
}

// MARK: - Decodable
public extension Dson {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        try self.init(string: rawString)
    }
}

// MARK: - Encodable
public extension Dson {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifer)
    }
}

// MARK: - CustomStringConvertible
public extension Dson {
    var description: String {
        return identifer
    }
}
