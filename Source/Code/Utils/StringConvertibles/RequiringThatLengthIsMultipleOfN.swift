//
//  RequiringThatLengthIsMultipleOfN.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol RequiringThatLengthIsMultipleOfN {
    static var lengthMultiple: Int { get }
    static func validateLengthMultiple<L>(of measurable: L) throws where L: LengthMeasurable
}

public extension RequiringThatLengthIsMultipleOfN {
    static func validateLengthMultiple<L>(of measurable: L) throws where L: LengthMeasurable {
        let length = measurable.length
        let multiple = Self.lengthMultiple
        if length % multiple != 0 {
            let (_, remainder) = length.quotientAndRemainder(dividingBy: multiple)
            throw InvalidStringError.lengthNotMultiple(of: multiple, shortOf: remainder)
        }
    }
}
