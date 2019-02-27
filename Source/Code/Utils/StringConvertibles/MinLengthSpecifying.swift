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
    static func validateMinLength<S>(of stringRepresentable: S) throws where S: StringRepresentable
    
}

public extension MinLengthSpecifying {
    static var minValue: Int {
        return minLength
    }

    static func validateMinLength<S>(of stringRepresentable: S) throws where S: StringRepresentable {
        let string = stringRepresentable.stringValue
        if string.count < minValue {
            throw InvalidStringError.tooFewCharacters(expectedAtLeast: minValue, butGot: string.count)
        }
    }
}
