//
//  StringValue.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

public struct StringValue:
    PrefixedJsonCodable,
    StringConvertible,
    StringRepresentable {
    // swiftlint:enable colon
    
    public let value: String
    
    public init(validated alwaysValid: String) {
        self.value = alwaysValid
    }
}
