//
//  NonNegativeAmountConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public protocol NonNegativeAmountConvertible:
    Amount,
    UnsignedNumeric
where
    Magnitude == BigUnsignedInt
{}

// swiftlint:enable colon opening_brace

// MARK: - Amount
public extension NonNegativeAmountConvertible {
    
    func negated() -> SignedAmount {
        return SignedAmount(validated: SignedAmount.Magnitude(sign: .minus, magnitude: magnitude))
    }
    
    var abs: NonNegativeAmount {
        return NonNegativeAmount(validated: magnitude)
    }
    
    var sign: AmountSign {
        return AmountSign(unsignedInt: magnitude)
    }
}

public extension NonNegativeAmountConvertible {
    static var maxValue256Bits: Self {
        return Self(validated: Magnitude(2).power(256) - 1)
    }
}

