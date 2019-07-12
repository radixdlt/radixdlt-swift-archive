//
//  Supply.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct Supply:
    Throwing,
    ValueValidating,
    Hashable,
    CustomStringConvertible
{
    // swiftlint:enable colon opening_brace
    
    public let amount: NonNegativeAmount
    
    public init(nonNegativeAmount: NonNegativeAmount) throws {
        self.amount = try Supply.validate(nonNegativeAmount)
    }
}

// MARK: - Convenience Init
public extension Supply {
    
    init<AmountType>(subtractingFromMax amountToSubtractFromMax: AmountType) throws where AmountType: NonNegativeAmountConvertible {
        try self.init(positiveAmount: Supply.subtractingFromMax(amount: amountToSubtractFromMax))
    }
    
    init(positiveAmount: PositiveAmount) throws {
        try self.init(nonNegativeAmount: NonNegativeAmount(positive: positiveAmount))
    }
    
    init(unallocatedTokensParticle: UnallocatedTokensParticle) {
        do {
            let unallocatedAmount = unallocatedTokensParticle.amount.amount
            try self.init(positiveAmount: Supply.subtractingFromMax(amount: unallocatedAmount))
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
    }
}

// MARK: - ValueValidating
public extension Supply {

    static let maxAmountValue = NonNegativeAmount.maxValue256Bits
    
    static func validate(_ value: NonNegativeAmount) throws -> NonNegativeAmount {
        if value > Supply.maxAmountValue {
            throw Error.cannotExceedUInt256MaxValue
        }
        return value
    }
}

// MARK: - Convenience
public extension Supply {
    var positiveAmount: PositiveAmount? {
        return try? PositiveAmount(nonNegative: amount)
    }
    
    var subtractedFromMax: Supply? {
        guard let positiveLeftOverSupplyAmount = try? Supply.subtractingFromMax(amount: self.amount) else { return nil }
        return try? Supply(positiveAmount: positiveLeftOverSupplyAmount)
    }
    
    static func subtractingFromMax<AmountType>(amount: AmountType) throws -> PositiveAmount where AmountType: NonNegativeAmountConvertible {
        return try PositiveAmount(nonNegative: Supply.maxAmountValue - NonNegativeAmount(validated: amount.magnitude))
    }
}

// MARK: - Arthimetic
public extension Supply {
    func add(_ other: Supply) throws -> Supply {
        return try Supply(nonNegativeAmount: amount + other.amount)
    }
}

// MARK: - Throwing
public extension Supply {
    enum Error: Swift.Error, Equatable {
        case cannotExceedUInt256MaxValue
    }
}

// MARK: - CustomStringConvertible
public extension Supply {
    var description: String {
        return amount.description
    }
}

// MARK: - Presets
public extension Supply {
    // swiftlint:disable force_try
    static let max = try! Supply(nonNegativeAmount: Supply.maxAmountValue)
    static let zero = try! Supply(nonNegativeAmount: 0)
    // swiftlint:enable force_try
}

// MARK: - Convenience
public extension Supply {
    func isExactMultipleOfGranularity(_ granularity: Granularity) -> Bool {
        return amount.isExactMultipleOfGranularity(granularity)
    }
}
