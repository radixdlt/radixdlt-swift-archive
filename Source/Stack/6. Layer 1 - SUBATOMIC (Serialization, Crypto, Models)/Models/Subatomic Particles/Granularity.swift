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

/// The smallest non-divisible amount of subunits one can have is introduced. For the formal definition read [RIP - Tokens][1].
///
/// - seeAlso:
/// `MutableSupplyTokenDefinitionParticle`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/407241467/RIP-2+Tokens
///
public typealias Granularity = UnsignedAmount<UInt256Bound, GranularityAmountTrait>
public extension Granularity {
    static var `default`: Self {
        return 1
    }
}

public typealias UInt256 = UnsignedAmount<UInt256Bound, NoTrait>

import BigInt

public protocol ValueBoundWhichIsSubsetOfOther: ValueBound where Self.Magnitude == Superset.Magnitude {
    associatedtype Superset: ValueBound
}
public extension ValueBoundWhichIsSubsetOfOther {
    
    static var greatestFiniteMagnitude: Magnitude { Superset.greatestFiniteMagnitude }
    
    static var leastNormalMagnitude: Magnitude { Superset.leastNormalMagnitude }
}

public struct UInt256Bound: ValueBound {}
public extension UInt256Bound {
    typealias Magnitude = BigUInt
    static var greatestFiniteMagnitude: Magnitude { Magnitude(2).power(256) - 1 }
    static var leastNormalMagnitude: Magnitude { 0 }
}

public struct UInt256NonZeroBound: ValueBoundWhichIsSubsetOfOther {}
public extension UInt256NonZeroBound {
    typealias Superset = UInt256Bound
    typealias Magnitude = BigUInt
    static var leastNormalMagnitude: Magnitude { 1 }
}

public typealias PositiveAmount = UnsignedAmount<UInt256NonZeroBound, TokenAmountTrait>
public typealias NonNegativeAmount = UnsignedAmount<UInt256Bound, TokenAmountTrait>

public protocol AmountTrait {}
public struct NoTrait: AmountTrait {}
public struct GranularityAmountTrait: AmountTrait {}
public struct TokenAmountTrait: AmountTrait {}
public struct SupplyAmountTrait: AmountTrait {}


public typealias Supply = UnsignedAmount<UInt256Bound, SupplyAmountTrait>
public typealias PositiveSupply = UnsignedAmount<UInt256NonZeroBound, SupplyAmountTrait>

public extension UnsignedAmountType {
    static var max: Self {
        do {
            return try Self.init(magnitude: Bound.greatestFiniteMagnitude)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Create max")
        }
    }
    
    static var min: Self {
        do {
            return try Self.init(magnitude: Bound.leastNormalMagnitude)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Create min")
        }
    }
}

public extension UnsignedAmountType {
    init(subtractedFromMax: Self) throws {
        let difference = try Self.subtraction(minuend: Self.max, subtrahend: subtractedFromMax)
        self = difference
    }
}

public extension UnsignedAmountType {
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
}


public extension UnsignedAmountType {
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
}


public extension UnsignedAmountType {
    init<Other>(related other: Other) throws
        where
        Other: UnsignedAmountType,
        Other.Bound.Magnitude == Self.Bound.Magnitude,
        Other.Trait == Self.Trait
    {
        try self.init(magnitude: other.magnitude, denomination: other.measuredIn)
    }
}

public extension UnsignedAmountType {
    init<Other>(unrelated other: Other) throws
        where
        Other: UnsignedAmountType,
        Other.Bound.Magnitude == Self.Bound.Magnitude
    {
        try self.init(magnitude: other.magnitude, denomination: other.measuredIn)
    }
}

public extension AmountType {
    init<I>(signed: I, denomination: Denomination = Self.measuredIn) throws where I: SignedInteger & MagnitudeType, I.Magnitude == Magnitude {
        guard signed.signum() >= 0 else {
            throw ValueError.valueCannotBeNegative
        }
        let magnitude = abs(signed).magnitude
        try self.init(magnitude: magnitude, denomination: Self.measuredIn)
    }
}

public extension UnsignedAmountType {
    func isMultiple<Other>(of other: Other) -> Bool where Other: UnsignedAmountType, Other.Magnitude == Self.Magnitude {
        magnitude.isMultiple(of: other.magnitude)
    }
}
