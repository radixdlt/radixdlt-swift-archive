//
//  SignedAmount.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BigInt

public protocol SignedAmount {
    var signedAmount: BigSignedInt { get }
    func negated() -> SignedAmount
}

public extension SignedAmount {
    static var zero: Amount {
        return Amount.zero
    }
}

public func + (lhs: SignedAmount, rhs: SignedAmount) -> SignedAmount {
    let amount = lhs.signedAmount + rhs.signedAmount
    if amount < 0 {
        return NegativeAmount(magnitude: amount.magnitude)
    } else {
        return Amount(value: amount.magnitude)
    }
}

public struct NegativeAmount: SignedAmount {
    private let magnitude: BigUnsignedInt
    
    public init(magnitude: BigUnsignedInt) {
        self.magnitude = magnitude
    }
    
    public var signedAmount: BigSignedInt {
        return BigSignedInt(sign: .minus, magnitude: magnitude)
    }
    
    public func negated() -> SignedAmount {
        return Amount(value: magnitude)
    }
}
