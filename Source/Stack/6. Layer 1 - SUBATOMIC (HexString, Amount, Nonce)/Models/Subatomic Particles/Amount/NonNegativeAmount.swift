//
//  NonNegativeAmount.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A non negative integer representing some amount, e.g. amount of tokens to transfer.
public struct NonNegativeAmount: NonNegativeAmountConvertible {
    public typealias Magnitude = BigUnsignedInt
    public let magnitude: Magnitude
    
    public init(validated: Magnitude) {
        self.magnitude = validated
    }
}

// MARK: - Zero
public extension NonNegativeAmount {
    static var zero: NonNegativeAmount {
        return NonNegativeAmount(validated: 0)
    }
}
