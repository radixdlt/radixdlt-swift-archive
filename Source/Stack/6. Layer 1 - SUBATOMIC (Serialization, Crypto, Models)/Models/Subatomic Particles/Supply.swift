/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

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
