//
//  StringInitializable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol StringInitializable: Codable, ValidValueInitializable where ValidationValue == String {}

extension String: StringInitializable {
    public static var jsonPrefix: JSONPrefix {
        return .string
    }
    
    public init(value string: String) throws {
        self = string
    }
}
