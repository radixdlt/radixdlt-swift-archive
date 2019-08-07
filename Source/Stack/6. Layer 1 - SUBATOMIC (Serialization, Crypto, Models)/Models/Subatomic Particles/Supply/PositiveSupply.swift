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

public struct PositiveSupply:
    Throwing,
    ValueValidating,
    Hashable,
    CustomStringConvertible
{
    // swiftlint:enable colon opening_brace
    
    public let amount: PositiveAmount
    
    public init(amount: PositiveAmount) throws {
        self.amount = try PositiveSupply.validate(amount)
    }
    
    public init(nonNegativeAmount: NonNegativeAmount) throws {
        let positiveAmount = try PositiveAmount(nonNegative: nonNegativeAmount)
        self.amount = try PositiveSupply.validate(positiveAmount)
    }
    
    public init(supply: Supply) throws {
        try self.init(nonNegativeAmount: supply.amount)
    }
    
    public init(subtractedFromMax supplyToSubtractFromMax: Supply) throws {
        let leftOverSupplyAmount = try supplyToSubtractFromMax.subtractedAmountFromMax()
        try self.init(nonNegativeAmount: leftOverSupplyAmount)
    }
}

// MARK: - ValueValidating
public extension PositiveSupply {
    
    static let maxAmountValue = PositiveAmount.maxValue256Bits
    
    static func validate(_ value: PositiveAmount) throws -> PositiveAmount {
        if value > Supply.maxAmountValue {
            throw Error.cannotExceedUInt256MaxValue
        }
        return value
    }
}

// MARK: - Arthimetic
public extension PositiveSupply {
    func add(_ other: PositiveSupply) throws -> PositiveSupply {
        return try PositiveSupply(amount: amount + other.amount)
    }
}

// MARK: - Throwing
public extension PositiveSupply {
    enum Error: Swift.Error, Equatable {
        case mustBePositive
        case cannotExceedUInt256MaxValue
    }
}

// MARK: - CustomStringConvertible
public extension PositiveSupply {
    var description: String {
        return amount.description
    }
}

// MARK: - Presets
public extension PositiveSupply {
    // swiftlint:disable force_try
    static let max = try! PositiveSupply(amount: PositiveSupply.maxAmountValue)
    // swiftlint:enable force_try
}

// MARK: - Convenience
public extension PositiveSupply {
    func isExactMultipleOfGranularity(_ granularity: Granularity) -> Bool {
        return amount.isExactMultipleOfGranularity(granularity)
    }
}
