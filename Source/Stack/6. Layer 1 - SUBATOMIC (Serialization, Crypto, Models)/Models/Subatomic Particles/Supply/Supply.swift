//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    
    public init(positiveSupply: PositiveSupply) {
        self.amount = NonNegativeAmount(positive: positiveSupply.amount)
    }
}

// MARK: - Convenience Init
public extension Supply {
    
    init(subtractingFromMax amountToSubtractFromMax: NonNegativeAmount) throws {
        try self.init(nonNegativeAmount: Supply.maxAmountValue - amountToSubtractFromMax)
    }
    
    init(positiveAmount: PositiveAmount) throws {
        try self.init(nonNegativeAmount: NonNegativeAmount(positive: positiveAmount))
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
    
    func subtractedAmountFromMax() throws -> NonNegativeAmount {
        return try Supply.subtractingFromMax(amount: amount)
    }
    
    static func subtractingFromMax(amount: NonNegativeAmount) throws -> NonNegativeAmount {
        return try Supply.maxAmountValue.subtracting(amount)
    }
    
}

// MARK: - Arthimetic
public extension Supply {
    func adding(_ other: Supply) throws -> Supply {
        return try Supply(nonNegativeAmount: amount + other.amount)
    }
    
    func subtracting(_ other: Supply) throws -> Supply {
        return try Supply(nonNegativeAmount: try amount.subtracting(other.amount))
    }
    
    func overflowsWhenAdding(_ other: Supply) -> Bool {
        do {
            _ = try adding(other)
            return false
        } catch Error.cannotExceedUInt256MaxValue {
            return true
        } catch { unexpectedlyMissedToCatch(error: error) }
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
