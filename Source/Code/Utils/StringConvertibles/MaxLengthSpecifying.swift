//
//  MaxLengthSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol MaxLengthSpecifying: UpperBound {
    static var maxLength: Int { get }
    static func validateMaxLength<L>(of measurable: L) throws where L: LengthMeasurable
}

public extension MaxLengthSpecifying {
    static var maxValue: Int {
        return maxLength
    }
    
    static func validateMaxLength<L>(of measurable: L) throws where L: LengthMeasurable {
        let length = measurable.length
        if length > maxLength {
            throw InvalidStringError.tooManyCharacters(expectedAtMost: maxLength, butGot: length)
        }
    }
}
