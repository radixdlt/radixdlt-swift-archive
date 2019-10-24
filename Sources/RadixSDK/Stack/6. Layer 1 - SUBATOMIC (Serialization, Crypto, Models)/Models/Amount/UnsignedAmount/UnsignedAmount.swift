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
import BigInt

// swiftlint:disable colon opening_brace

public struct UnsignedAmount<Bound, Trait>:
    UnsignedAmountType,
    PrefixedJSONCodable,
    StringRepresentable,
    CBORDataConvertible,
    CustomStringConvertible
where
    Trait: AmountTrait,
    Bound: ValueBound,
    Bound.Magnitude: StringRepresentable & StringInitializable
{
    // swiftlint:enable colon opening_brace
    public typealias Magnitude = Bound.Magnitude
    
    /// `magnitude` measured in  denomination `measuredIn` (`Denomination`)
    public let magnitude: Magnitude
    
    internal init(magnitudeInSmallestPossibleDenomination: Magnitude) throws {
        try Bound.contains(value: magnitudeInSmallestPossibleDenomination)
        self.magnitude = magnitudeInSmallestPossibleDenomination
    }
    
    public init(magnitude: Magnitude, denomination: Denomination = Self.measuredIn) throws {
        try self.init(
            magnitudeInSmallestPossibleDenomination: denomination.expressMagnitudeInSmallestPossibleDenomination(magnitude))
    }
}

// MARK: - Throwing
extension UnsignedAmount: Throwing {}
public extension UnsignedAmount {
    enum Error: Swift.Error, Equatable {
        case stringNotANumber(String)
        case amountMustBePositive
        case amountInAttoIsOnlyMeasuredInIntegers(butPassedDouble: Double)
        case amountFromStringNotRepresentableInDenomination(amountString: String, specifiedDenomination: Denomination)
    }
}

public extension UnsignedAmount {
    typealias Words = Bound.Magnitude.Words
    typealias IntegerLiteralType = Bound.Magnitude.IntegerLiteralType
    
    // For some strange reason declaring this computed property as an extension of the protocol
    // `UnsignedAmountType` resulted in infinite recursion crash when writing the compare
    // expression `someAmount > 0` (<- where `0` is a literal). Might be a red herring, but
    // moving `words` from protocol to this concrete existential breaks the recursion.
    var words: Words { magnitude.words }
}

// MARK: CustomStringConvertible
public extension UnsignedAmount {
    var description: String {
        return format(amount: magnitude, denomination: self.measuredIn)
    }
    
    func display(in desiredDenomination: Denomination, displayDenomination: Bool = false) throws -> String {
        let converted = try Denomination.convertMagnitude(magnitude, from: self.measuredIn, to: desiredDenomination)
        return format(amount: converted, denomination: displayDenomination ? desiredDenomination : nil)
    }
    
    func displayUsingHighestPossibleNamedDenominator(displayDenomination: Bool = false) -> String {
        let (amount, denomination) = expressedInBiggestPossibleDenomination()
        return format(amount: amount, denomination: displayDenomination ? denomination : nil)
    }
}

// MARK: - Conversion
public extension UnsignedAmount {
    
    func expressedInBiggestPossibleDenomination() -> (amount: Magnitude, denomination: Denomination) {
        
        for denomination in Denomination.allCases.sorted().reversed() {
            if let convertedAmount = try? Denomination.convertMagnitude(magnitude, from: self.measuredIn, to: denomination) {
                return (amount: convertedAmount, denomination: denomination)
            }
        }
        return (amount: magnitude, denomination: self.measuredIn)
    }
    
}

public extension UnsignedAmountType {
    func isMultiple<Other>(of other: Other) -> Bool where Other: UnsignedAmountType, Other.Magnitude == Self.Magnitude {
        magnitude.isMultiple(of: other.magnitude)
    }
}

private extension UnsignedAmount {
    func format(amount: Magnitude, denomination: Denomination?) -> String {
        if let denomination = denomination {
            return "\(amount) \(denomination.name) (\(denomination.exponentSuperscript))"
        } else {
            return "\(amount)"
        }
    }
}

// MARK: - Numeric Init
public extension UnsignedAmount {
    
    init?<T>(exactly source: T) where T: BinaryInteger {
        guard let fromSource = Magnitude(exactly: source) else { return nil }
        try? self.init(magnitude: fromSource)
    }
}

// MARK: DSONPrefixSpecifying
public extension UnsignedAmount {
    var dsonPrefix: DSONPrefix {
        return .unsignedBigInteger
    }
}

// MARK: - DataConvertible
public extension UnsignedAmount {
    var asData: Data {
        return magnitude.toData(minByteCount: 32)
    }
}

// MARK: - StringInitializable
public extension UnsignedAmount {

    init(string: String) throws {
        let decimalString = try DecimalString(unvalidated: string)
        try self.init(string: decimalString.stringValue, denomination: Self.measuredIn)
    }

}

// MARK: - StringRepresentable
public extension UnsignedAmount {
    var stringValue: String {
        return magnitude.stringValue
    }
}

// MARK: - PrefixedJSONDecodable
public extension UnsignedAmount {
    static var jsonPrefix: JSONPrefix { return .uint256DecimalString }
}

// MARK: - From Binary Integer
public extension UnsignedAmount {
    init<Integer>(integer: Integer) throws where Integer: BinaryInteger {
        try self.init(magnitude: Magnitude(integer))
    }
}
