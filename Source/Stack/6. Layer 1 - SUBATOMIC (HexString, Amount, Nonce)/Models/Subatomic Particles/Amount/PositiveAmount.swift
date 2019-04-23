//
//  UnsignedAmount.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A strictly positive integer representing some amount, e.g. amount of tokens to transfer.
public struct PositiveAmount: Amount, UnsignedNumeric, Throwing {
    
    public typealias Magnitude = BigUnsignedInt
    public let magnitude: Magnitude
    
    public init(validated: Magnitude) {
        self.magnitude = validated
    }
    
    public init(validating unvalidated: Magnitude) throws {
        if unvalidated == 0 {
            throw Error.amountCannotBeZero
        }
        let validated = unvalidated
        self.init(validated: validated)
    }
}

// MARK: - Throwing
public extension PositiveAmount {
    enum Error: Swift.Error, Equatable {
        case amountCannotBeZero
    }
}

// MARK: - Amount
public extension PositiveAmount {
    
    func negated() -> SignedAmount {
        return SignedAmount(validated: SignedAmount.Magnitude(sign: .minus, magnitude: magnitude))
    }
    
    var abs: PositiveAmount { return self }
    
}

// MARK: - Extra
public extension PositiveAmount {
    static var maxValue256Bits: PositiveAmount {
        return PositiveAmount(validated: Magnitude(2).power(256) - 1)
    }
    
    // MARK: - Subunits
    static var subunitsDenominatorDecimalExponent: Int { return 18 }
    static var subunitsDenominator: Magnitude { return Magnitude(10).power(PositiveAmount.subunitsDenominatorDecimalExponent) }
}

// MARK: - BigUnsignedInt + StringInitializable
extension BigUnsignedInt: StringInitializable {
    
    public init(string: String) throws {
        guard let fromString = BigUnsignedInt(string, radix: 10) else {
            throw InvalidStringError.invalidCharacters(expectedCharacters: CharacterSet.decimalDigits, butGot: string)
        }
        self = fromString
    }
}

// MARK: - BigUnsignedInt + StringRepresentable
extension BigUnsignedInt: StringRepresentable {
    public var stringValue: String {
        return self.toDecimalString()
    }
}
