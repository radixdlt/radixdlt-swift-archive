//
//  MetaDataKey.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// Open enum
public struct MetaDataKey:
    PrefixedJsonCodable,
    StringInitializable,
    StringRepresentable,
    Hashable,
    CustomStringConvertible {

// swiftlint:enable colon

    public let key: String
    
    public init(_ key: String) {
        self.key = key
    }
}

// MARK: - StringInitializable
public extension MetaDataKey {
    init(string: String) throws {
        self.init(string)
    }
}

// MARK: - StringRepresentable
public extension MetaDataKey {
    var stringValue: String {
        return key
    }
}

// MARK: - CustomStringConvertible
public extension MetaDataKey {
    var description: String {
        return key
    }
}

// MARK: - Presets
public extension MetaDataKey {
    static let timestamp: MetaDataKey   = "timestamp"
    static let proofOfWork: MetaDataKey = "powNonce"
    static let application: MetaDataKey = "application"
    static let contentType: MetaDataKey = "contentType"
    static let encrypted: MetaDataKey = "encrypted"
}
