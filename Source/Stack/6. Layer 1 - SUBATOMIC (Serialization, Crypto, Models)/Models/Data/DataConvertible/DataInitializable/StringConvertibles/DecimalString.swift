//
//  DecimalString.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-06.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// String representation of a Hex string which is impossible to instantiatie with invalid values.
public struct DecimalString:
    StringConvertible,
    StringRepresentable,
    CharacterSetSpecifying
{
    // swiftlint:enable colon opening_brace
    
    public static var allowedCharacters = CharacterSet.decimalDigits
    
    public let value: String
    
    public init(validated unvalidated: String) {
        do {
            self.value = try DecimalString.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - StringRepresentable
public extension DecimalString {
    var stringValue: String {
        return value
    }
}
