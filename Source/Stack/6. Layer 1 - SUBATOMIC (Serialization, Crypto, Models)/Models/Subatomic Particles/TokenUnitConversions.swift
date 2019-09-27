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

/// Converting between denominations
public enum TokenUnitConversions {}

public extension TokenUnitConversions {
    /// Returns the specified number of subunits as a fractional number of units.
    ///
    /// This method effectively calculates:
    /// `subunits * 10^{-Granularity.subunitsDenominatorDecimalExponent}`
    ///
    /// This is only used for displaying purposes.
    static func subunitsToUnits<NNA>(_ subunits: NNA) -> NNA where NNA: NonNegativeAmountConvertible {
        let amount = subunits.magnitude
        let exponent = Granularity.subunitsDenominatorDecimalExponent
        let factor = BigUnsignedInt(10).power(exponent)
        let (quotient, remainder) = amount.quotientAndRemainder(dividingBy: factor)
        if remainder != 0 {
            fatalError("Count not divide, remainder is not zero, amount: \(amount), factor: \(factor), ")
        }
        return NNA.init(validated: quotient)
    }
    
    /// Returns the specified number of subunits as a fractional number of units.
    ///
    /// This method effectively calculates:
    /// `units * 10^{Granularity.subunitsDenominatorDecimalExponent}`
    ///
    /// This is only used for displaying purposes.
    static func unitsToSubunits<NNA>(_ units: NNA) -> NNA where NNA: NonNegativeAmountConvertible {
        let amount = units.magnitude
        let exponent = Granularity.subunitsDenominatorDecimalExponent
        let factor = BigUnsignedInt(10).power(exponent)
        return NNA.init(validated: amount.multiplied(by: factor))
    }
}
