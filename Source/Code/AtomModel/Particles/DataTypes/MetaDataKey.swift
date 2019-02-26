//
//  MetaDataKey.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Open enum
public struct MetaDataKey: Hashable, CustomStringConvertible, Codable {

    public let key: String
    
    public init(_ key: String) {
        self.key = key
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
    static let timestamp = MetaDataKey("timestamp")
}
