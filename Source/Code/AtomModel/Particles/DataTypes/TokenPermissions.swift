//
//  TokenPermissions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenPermissions: DictionaryDecodable, Equatable {
    public typealias Key = TokenAction
    public typealias Value = TokenPermission
    public let dictionary: [Key: Value]
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
}

// MARK: - Encodable
public extension TokenPermissions {
    func encode(to encoder: Encoder) throws {
       implementMe
    }
}

