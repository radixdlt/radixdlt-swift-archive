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

public protocol NonNegativeAmountConvertible:
    Amount,
    UnsignedNumeric
where
    Magnitude == BigUnsignedInt
{
    func subtracting(_ other: Self) throws -> Self
    init<NNA>(nonNegative: NNA) where NNA: NonNegativeAmountConvertible
}

public extension NonNegativeAmountConvertible {
    
    init<NNA>(nonNegative: NNA) where NNA: NonNegativeAmountConvertible {
        self.init(validated: nonNegative.magnitude)
    }
}

// swiftlint:enable colon opening_brace

public extension NonNegativeAmountConvertible {
    func subtracting(_ other: Self) throws -> Self {
        let lhs = SignedAmount(nonNegative: self)
        let rhs = SignedAmount(nonNegative: other)
        let result = lhs - rhs
        switch result.amountAndSign {
        case .negative:
            throw NonNegativeAmountError.subtractionResultsInNegativeValue(
                lhs: lhs.abs,
                rhs: rhs.abs,
                negativeResult: result
            )
        case .zero:
            do {
                return try Self.init(validating: 0)
            } catch {
                throw NonNegativeAmountError.subtractionResultsInZeroWhichIsNotAllowed(
                    lhs: lhs.abs,
                    rhs: rhs.abs
                )
            }
        case .positive(let positiveAmount):
            return Self.init(validated: positiveAmount)
        }
    }
}

public enum NonNegativeAmountError: Swift.Error, Equatable {
    case subtractionResultsInNegativeValue(
        lhs: NonNegativeAmount,
        rhs: NonNegativeAmount,
        negativeResult: SignedAmount
    )
    case subtractionResultsInZeroWhichIsNotAllowed(
        lhs: NonNegativeAmount,
        rhs: NonNegativeAmount
    )
}

// MARK: - Amount
public extension NonNegativeAmountConvertible {
    
    func negated() -> SignedAmount {
        let negatedMagnitude: SignedAmount.Magnitude = .init(sign: .minus, magnitude: magnitude)
        return SignedAmount(validated: negatedMagnitude)
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

