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
}

// MARK: - Amount
public extension SignedAmount {
    func negated() -> SignedAmount {
        return SignedAmount(validated: -1 * magnitude)
    }
    
    var abs: NonNegativeAmount {
        return NonNegativeAmount(validated: NonNegativeAmount.Magnitude(Swift.abs(magnitude)))
    }
}

// MARK: - Zero
public extension SignedAmount {
    static var zero: SignedAmount {
        return SignedAmount(validated: 0)
    }
}
