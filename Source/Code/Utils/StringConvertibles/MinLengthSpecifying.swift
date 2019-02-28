//
//  MinLengthSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol MinLengthSpecifying: LowerBound {
    static var minLength: Int { get }
    static func validateMinLength<L>(of measurable: L) throws where L: LengthMeasurable
    
}

public extension MinLengthSpecifying {
    static var minValue: Int {
        return minLength
    }

    static func validateMinLength<L>(of measurable: L) throws where L: LengthMeasurable {
        let length = measurable.length
        if length < minLength {
            throw InvalidStringError.tooFewCharacters(expectedAtLeast: minLength, butGot: length)
        }
    }
}
