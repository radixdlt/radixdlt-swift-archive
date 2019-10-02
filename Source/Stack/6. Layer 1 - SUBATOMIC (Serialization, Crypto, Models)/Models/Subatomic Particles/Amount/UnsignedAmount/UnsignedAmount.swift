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

public protocol BinaryIntegerFromString { // LosslessStringConvertible ?
    init?<S>(_ text: S, radix: Int) where S: StringProtocol
}

public typealias MagnitudeType = BinaryInteger & BinaryIntegerFromString & Codable

extension BigUInt: BinaryIntegerFromString {}
extension BigInt: BinaryIntegerFromString {}
extension UInt64: BinaryIntegerFromString {}
extension UInt32: BinaryIntegerFromString {}
extension UInt16: BinaryIntegerFromString {}
extension UInt8: BinaryIntegerFromString {}
extension Int64: BinaryIntegerFromString {}
extension Int32: BinaryIntegerFromString {}
extension Int16: BinaryIntegerFromString {}
extension Int8: BinaryIntegerFromString {}

public protocol ValueBound where Magnitude.Magnitude == Magnitude {
    associatedtype Magnitude: MagnitudeType
    static var isSigned: Bool { get }
    
    /// Greatest possible magnitude measured in the smallest possible `Denomination` (`Denomination.minExponent`)
    static var greatestFiniteMagnitude: Magnitude { get }
    
    /// Smallest possible magnitude measured in the smallest possible `Denomination` (`Denomination.minExponent`)
    static var leastNormalMagnitude: Magnitude { get }
    
    static func contains(value: Magnitude) throws
}

public enum ValueError: Swift.Error, Equatable {
    case valueTooBig
    case valueTooSmall
    case valueCannotBeNegative
}

public extension ValueBound {
    static var isSigned: Bool { Magnitude.isSigned }
    static func contains(value: Magnitude) throws {
        if value > Self.greatestFiniteMagnitude { throw ValueError.valueTooBig }
        if value < Self.leastNormalMagnitude { throw ValueError.valueTooSmall }
        // all is well
    }
}

public protocol AmountType: BinaryInteger where Bound.Magnitude == Self.Magnitude {
    associatedtype Bound: ValueBound
    associatedtype Trait: AmountTrait
    init(magnitude: Magnitude, denomination: Denomination) throws
}

public extension AmountType {
    static var measuredIn: Denomination { .min } // hard code to Denomination.min
    var measuredIn: Denomination { Self.measuredIn }
    init(magnitude: Magnitude) throws {
        try self.init(magnitude: magnitude, denomination: Self.measuredIn)
    }
}

public protocol UnsignedAmountType: AmountType & UnsignedInteger {
    
    static func multiplication(_ lhs: Self, _ rhs: Self) throws -> Self
    static func addition(_ lhs: Self, _ rhs: Self) throws -> Self
    static func subtraction(minuend: Self, subtrahend: Self) throws -> Self
}

public extension UnsignedAmountType {
//    subtracting
    func multiplying(with factor: Self) throws -> Self {
        try Self.multiplication(self, factor)
    }
    func adding(term: Self) throws -> Self {
        try Self.addition(self, term)
    }
    func subtracting(subtrahend: Self) throws -> Self {
        try Self.subtraction(minuend: self, subtrahend: subtrahend)
    }
}

public struct UnsignedAmount<Bound, Trait>:
    UnsignedAmountType,
    PrefixedJSONCodable,
    StringRepresentable,
    CBORDataConvertible,
    Numeric,
    Comparable,
    CustomStringConvertible
where
    Trait: AmountTrait,
    Bound: ValueBound,
    Bound.Magnitude: BigInteger & StringRepresentable & StringInitializable
//    Magnitude: BigInteger & StringRepresentable & StringInitializable
{
    // swiftlint:enable colon opening_brace
    public typealias Magnitude = Bound.Magnitude
    
    /// `magnitude` measured in  denomination `measuredIn` (`Denomination`)
    public let magnitude: Magnitude
    
    private init(magnitudeInSmallestPossibleDenomination: Magnitude) throws {
        try Bound.contains(value: magnitudeInSmallestPossibleDenomination)
        self.magnitude = magnitudeInSmallestPossibleDenomination
    }
    
    public init(magnitude: Magnitude, denomination: Denomination = Self.measuredIn) throws {
        let magnitudeInSmallestPossibleDenomination = denomination.expressValueInSmallestPossibleDenomination(value: magnitude)
        try self.init(magnitudeInSmallestPossibleDenomination: magnitudeInSmallestPossibleDenomination)
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
        case amountNotRepresentableAsIntegerInDenomination(amount: UnsignedAmount.Magnitude, fromDenomination: Denomination, toDenomination: Denomination)
    }
}

public extension UnsignedAmount {
    typealias Words = Bound.Magnitude.Words
    typealias IntegerLiteralType = Bound.Magnitude.IntegerLiteralType
}

public extension UnsignedAmount {
    
    var denomination: Denomination { .atto }
    
    init(string: String, denomination from: Denomination) throws {
        let numberFormatter: NumberFormatter = .default
        let decimalSeparator = Locale.decimalSeparatorIndeed
        
        func magnitudeFromNonDecimalString(_ nonDecimalString: String) throws -> Magnitude {
            
            assert(!nonDecimalString.contains(decimalSeparator))
            guard let magnitudeFromString = Magnitude(nonDecimalString, radix: 10) else {
                throw Error.stringNotANumber(string)
            }
            guard magnitudeFromString > .zero else {
                throw Error.amountMustBePositive
            }
            return magnitudeFromString
            
        }
        
        if let decimalSeparatorIndex = string.index(of: decimalSeparator) {
            let numberOfDecimals = string.distance(from: decimalSeparatorIndex, to: string.endIndex) - 1
            let exponentDelta = abs(Self.measuredIn.exponent - from.exponent)
            
            if exponentDelta < numberOfDecimals {
                throw Error.amountFromStringNotRepresentableInDenomination(amountString: string, specifiedDenomination: from)
            } else {
                let amountStringWithDecimalDropped = string.replacingOccurrences(of: decimalSeparator, with: "")
                var amountMeasuredInAttoDroppedDecimals = try magnitudeFromNonDecimalString(amountStringWithDecimalDropped)
                
                if exponentDelta > numberOfDecimals {
                    let exponent = exponentDelta - numberOfDecimals
                   
                    let factorInt = Int(pow(Double(10), Double(exponent)))
                    let factor = Magnitude(factorInt)
                    amountMeasuredInAttoDroppedDecimals *= factor
                }
                
                try self.init(magnitudeInSmallestPossibleDenomination: amountMeasuredInAttoDroppedDecimals)
            }
        } else {
            let magnitudeUnconverted = try magnitudeFromNonDecimalString(string)
            try self.init(magnitude: magnitudeUnconverted, denomination: from)
        }
    }
    
    @available(*, deprecated, message: "_NOT_ deprecated, but a word of caution: `Double` might lose precision after a certain amount of decimals, consider using `init(positiveAmount:denomination)` or `init(string:denomination)` (which this init delegates to anyway) instead")
    init(double: Double, denomination from: Denomination) throws {
        guard from.exponent > Self.measuredIn.exponent else {
            throw Error.amountInAttoIsOnlyMeasuredInIntegers(butPassedDouble: double)
        }
        guard let numberString = NumberFormatter.default.string(from: NSNumber(value: double)) else {
            incorrectImplementationShouldAlwaysBeAble(to: "Format a number string from double value: \(double)")
        }
        try self.init(string: numberString, denomination: from)
    }
}

// MARK: CustomStringConvertible
public extension UnsignedAmount {
    var description: String {
        return format(amount: magnitude, denomination: self.measuredIn)
    }
    
    func display(in desiredDenomination: Denomination) throws -> String {
        let converted = try Self.convertMagnitude(magnitude, from: self.denomination, to: desiredDenomination)
        return format(amount: converted, denomination: desiredDenomination)
    }
    
    func displayUsingHighestPossibleNamedDenominator() -> String {
        let (amount, denomination) = expressedInBiggestPossibleDenomination()
        return format(amount: amount, denomination: denomination)
    }
}

// MARK: - Conversion
public extension UnsignedAmount {
    
    static func convertMagnitude(
        _ magnitude: Magnitude,
        from: Denomination,
        to: Denomination
    ) throws -> Magnitude {
        
        let exponentDelta = abs(to.exponent - from.exponent)
        let factorInt = Int(pow(Double(10), Double(exponentDelta)))
        let factor = Magnitude(factorInt)
        
        if from == to {
            return magnitude
        } else if from > to {
//            return NNA.init(validated: magnitude.multiplied(by: scale))
            return magnitude * factor
        } else if from < to {
            let (quotient, remainder) = magnitude.quotientAndRemainder(dividingBy: factor)
            guard remainder == 0 else {
                throw Error.amountNotRepresentableAsIntegerInDenomination(
                    amount: magnitude,
                    fromDenomination: from,
                    toDenomination: to
                )
            }
            
            return quotient
        } else { incorrectImplementation("All cases should have been handled already.") }
    }
    
    func expressedInBiggestPossibleDenomination() -> (amount: Magnitude, denomination: Denomination) {
        
        for denomination in Denomination.allCases.sorted().reversed() {
            if let convertedAmount = try? Self.convertMagnitude(magnitude, from: self.denomination, to: denomination) {
                return (amount: convertedAmount, denomination: denomination)
            }
        }
        return (amount: magnitude, denomination: self.denomination)
    }
    
}

private extension UnsignedAmount {
    func format(amount: Magnitude, denomination: Denomination) -> String {
        return "\(amount) \(denomination.name) (\(denomination.exponentSuperscript))"
    }
}

// MARK: - Numeric Init
public extension UnsignedAmount {
    
    init?<T>(exactly source: T) where T: BinaryInteger {
        guard let fromSource = Magnitude(exactly: source) else { return nil }
        try? self.init(magnitude: fromSource)
    }
}

// MARK: - Numeric Operators
public extension UnsignedAmount {
    
    /// Multiplies two values and produces their product.
    static func multiplication(_ lhs: Self, _ rhs: Self) throws -> Self {
        try calculate(lhs, rhs, operation: *)
    }
    
    /// Multiplies two values and produces their product.
    static func * (lhs: Self, rhs: Self) -> Self {
        calculateOrCrash(lhs, rhs, multiplication)
    }
    
    /// Adds two values and produces their sum.
    static func addition(_ lhs: Self, _ rhs: Self) throws -> Self {
        try calculate(lhs, rhs, operation: +)
    }

    /// Adds two values and produces their sum.
    static func + (lhs: Self, rhs: Self) -> Self {
        calculateOrCrash(lhs, rhs, addition)
    }
    
    /// Subtracts one value from another and produces their difference.
    static func subtraction(minuend: Self, subtrahend: Self) throws -> Self {
        try calculate(minuend, subtrahend,
                      willOverflowIf: subtrahend > minuend,
                      operation: -)
    }
    
    /// Subtracts one value from another and produces their difference.
    static func - (lhs: Self, rhs: Self) -> Self {
        calculateOrCrash(lhs, rhs, subtraction)
    }
}

// MARK: - Numeric Operators Inout
public extension UnsignedAmount {
    
    /// Adds two values and stores the result in the left-hand-side variable.
    static func += (lhs: inout Self, rhs: Self) {
        // swiftlint:disable:next shorthand_operator
        lhs = lhs + rhs
    }
    
    /// Subtracts the second value from the first and stores the difference in the left-hand-side variable.
    static func -= (lhs: inout Self, rhs: Self) {
        // swiftlint:disable:next shorthand_operator
        lhs = lhs - rhs
    }
    
    /// Multiplies two values and stores the result in the left-hand-side variable.
    static func *= (lhs: inout Self, rhs: Self) {
        // swiftlint:disable:next shorthand_operator
        lhs = lhs * rhs
    }
}

// MARK: Global Operators
//public func * <A>(spin: Spin, amount: A) -> SignedAmount where A: Amount {
//    switch spin {
//    case .down, .neutral: return amount.negated()
//    case .up: return SignedAmount(validated: SignedAmount.Magnitude(amount.magnitude))
//    }
//}

// MARK: - Private Helper
private extension UnsignedAmount {
    
    static func calculateOrCrash(_ lhs: Self, _ rhs: Self, _ function: (Self, Self) throws -> Self) -> Self {
        do {
            return try function(lhs, rhs)
        } catch {
            fatalError("Error performing arithmetic between (lhs: \(lhs), rhs: \(rhs)), error: \(error)")
        }
    }
    
//    static func calculateOrCrash(_ lhs: Self, _ rhs: Self,
//        willOverflowIf overflowCheck: @autoclosure () -> Bool = { false }(),
//        operation: (Magnitude, Magnitude) -> Magnitude
//    ) -> Self {
//        do {
//            return calculate(lhs, rhs, willOverflowIf: overflowCheck, operation: operation)
//        } catch {
//            fatalError("Error performing arithmetic between amounts, error: \(error)")
//        }
//    }
    
    static func calculate(
        _ lhs: Self,
        _ rhs: Self,
        willOverflowIf overflowCheck: @autoclosure () -> Bool = { false }(),
        operation: (Magnitude, Magnitude) -> Magnitude
    ) throws -> Self {
        precondition(overflowCheck() == false, "Overflow")
        
        return try Self(magnitude: operation(lhs.magnitude, rhs.magnitude))
    }
    
}

// MARK: - Comparable
public extension UnsignedAmount {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.magnitude < rhs.magnitude
    }
    static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.magnitude > rhs.magnitude
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.magnitude == rhs.magnitude
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
        let magnitude = try Magnitude.init(string: string)
        try self.init(magnitude: magnitude)
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

// MARK: - ExpressibleByIntegerLiteral
public extension UnsignedAmount {
    init(integerLiteral magnitudeIntegerLiteral: Magnitude.IntegerLiteralType) {
        do {
            try self.init(magnitude: Magnitude.init(integerLiteral: magnitudeIntegerLiteral))
        } catch {
            badLiteralValue(magnitudeIntegerLiteral, error: error)
        }
    }
}
