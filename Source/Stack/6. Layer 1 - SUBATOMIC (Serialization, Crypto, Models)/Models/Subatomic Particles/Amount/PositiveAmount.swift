//
//  PositiveAmount.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A strictly positive integer representing some amount, e.g. amount of tokens to transfer.
public struct PositiveAmount: NonNegativeAmountConvertible, Throwing {
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
        case amountCannotBeNegative
    }
}

// MARK: - From NonNegativeAmount
public extension PositiveAmount {
    init(nonNegative: NonNegativeAmount) throws {
        try self.init(validating: nonNegative.magnitude)
    }
}

// MARK: - From SignedAmount
public extension PositiveAmount {
    init(signedAmount: SignedAmount) throws {
        switch signedAmount.amountAndSign {
        case .positive(let positive):
            self.init(validated: positive)
        case .zero: throw Error.amountCannotBeZero
        case .negative: throw Error.amountCannotBeNegative
        }
    }
}
