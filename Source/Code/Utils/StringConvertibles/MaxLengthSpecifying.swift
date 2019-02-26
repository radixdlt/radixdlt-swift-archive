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
    static func validateMaxLength<S>(of stringRepresentable: S) throws where S: StringRepresentable
}

public extension MaxLengthSpecifying {
    static var maxValue: Int {
        return maxLength
    }
    
    static func validateMaxLength<S>(of stringRepresentable: S) throws where S: StringRepresentable {
        let string = stringRepresentable.stringValue
        if string.count > maxValue {
            throw InvalidStringError.tooManyCharacters(expectedAtMost: maxValue, butGot: string.count)
        }
    }
}
