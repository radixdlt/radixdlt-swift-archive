//
//  SignedAmount.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SignedAmount: Amount, SignedNumeric {
    
    public typealias Magnitude = BigSignedInt
    
    public let magnitude: Magnitude
    public init(validated: Magnitude) {
        self.magnitude = validated
    }
    public init(validating: Magnitude) throws {
        self.init(validated: validating)
    }
}

// MARK: - Amount
public extension SignedAmount {
    func negated() -> SignedAmount {
        return SignedAmount(validated: -1 * magnitude)
    }
    var abs: PositiveAmount {
        return PositiveAmount(validated: PositiveAmount.Magnitude(Swift.abs(magnitude)))
    }
}

// MARK: - Zero
public extension SignedAmount {
    static var zero: SignedAmount {
        return SignedAmount(validated: 0)
    }
}

// MARK: - BigSignedInt + StringInitializable
extension BigSignedInt: StringInitializable {
    
    public init(string: String) throws {
        guard let fromString = BigSignedInt(string, radix: 10) else {
            throw InvalidStringError.invalidCharacters(expectedCharacters: CharacterSet.decimalDigits, butGot: string)
        }
        self = fromString
    }
}

// MARK: - BigSignedInt + StringRepresentable
extension BigSignedInt: StringRepresentable {
    public var stringValue: String {
        return self.toDecimalString()
    }
}
