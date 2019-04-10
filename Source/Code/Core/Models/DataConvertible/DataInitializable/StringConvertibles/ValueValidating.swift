//
//  ValueValidating.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ValueValidating {
    associatedtype ValidationValue
    static func validate(_ value: ValidationValue) throws -> ValidationValue
}

public extension ValueValidating where ValidationValue: LengthMeasurable {
    static func validate(_ value: ValidationValue) throws -> ValidationValue {
        if let string = value as? String {
            try (self as? CharacterSetSpecifying.Type)?.validateCharacters(in: string)
        }
        try (self as? MinLengthSpecifying.Type)?.validateMinLength(of: value)
        try (self as? MaxLengthSpecifying.Type)?.validateMaxLength(of: value)
        try (self as? RequiringThatLengthIsMultipleOfN.Type)?.validateLengthMultiple(of: value)
        return value
    }
}
