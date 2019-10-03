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

// swiftlint:disable opening_brace

public extension UnsignedAmountType {
    
    init(_ other: Self) {
        self = other
    }
    
    init<Other>(subset other: Other)
        where
        Other: UnsignedAmountType,
        Other.Bound: ValueBoundWhichIsSubsetOfOther,
        Other.Bound.Superset == Self.Bound
        // , Other.Trait == Self.Trait
    {
        do {
            try self.init(magnitude: other.magnitude, denomination: other.measuredIn)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Create from Other if `Bound: ValueBoundWhichIsSubsetOfOther`", error)
        }
    }
    
    init<Other>(other: Other)
        where
        Other: UnsignedAmountType,
        Other.Bound == Self.Bound
        //        , Other.Trait == Self.Trait
    {
        do {
            try self.init(magnitude: other.magnitude, denomination: other.measuredIn)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Create from Other if `Bound`s equal", error)
        }
    }
    
    init<Other>(related other: Other) throws
        where
        Other: UnsignedAmountType,
        Other.Bound.Magnitude == Self.Bound.Magnitude,
        Other.Trait == Self.Trait
    {
        try self.init(magnitude: other.magnitude, denomination: other.measuredIn)
    }
    
    init<Other>(unrelated other: Other) throws
        where
        Other: UnsignedAmountType,
        Other.Bound.Magnitude == Self.Bound.Magnitude
    {
        try self.init(magnitude: other.magnitude, denomination: other.measuredIn)
    }
    
    init<I>(signed: I, denomination: Denomination = Self.measuredIn) throws where I: SignedInteger & MagnitudeType, I.Magnitude == Magnitude {
        guard signed.signum() >= 0 else {
            throw AmountError.valueCannotBeNegative
        }
        let magnitude = abs(signed).magnitude
        try self.init(magnitude: magnitude, denomination: Self.measuredIn)
    }
    
    init(subtractedFromMax subtrahend: Self) throws {
        let difference = try Self.subtraction(minuend: Self.max, subtrahend: subtrahend)
        self = difference
    }
    
    init(subtractedFromMax subtrahendMagnitude: Magnitude) throws {
        let differenceMagnitude = try Self.subtractionMagnitude(minuend: Self.max.magnitude, subtrahend: subtrahendMagnitude)
        try self.init(magnitude: differenceMagnitude)
    }
    
    init<Other>(subtractedFromMax subtrahendOther: Other) throws where Other: UnsignedAmountType, Other.Bound == Self.Bound {
        let subtrahend = Self(other: subtrahendOther)
        try self.init(subtractedFromMax: subtrahend)
    }
}

// swiftlint:enable opening_brace
