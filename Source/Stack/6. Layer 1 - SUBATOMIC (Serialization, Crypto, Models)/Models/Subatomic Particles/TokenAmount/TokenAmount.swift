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

public struct TokenAmount: Comparable, CustomStringConvertible {
    
    /// The use can never spend negative amounts, nor can she create a token with a negative supply, thus safe to bound to at least `NonNegativeAmount`. But since the zero amount (`0`) is not so relevant, we skip support for that.
    public let amountMeasuredInAtto: PositiveAmount
    
    /// `amount` is a non negative integer type, we do not allow dealing with decimal values due to lack of `BigDecimal` in Swift. Using Swift standard library (`Foundation`)'s number type `Decimal` does not provide us with enough precision.
    ///
    public init(positiveAmount nonConvertedAmount: PositiveAmount, denomination from: Denomination) {
        self.amountMeasuredInAtto = Self.convertToAtto(amount: nonConvertedAmount, from: from)
    }
}

public extension TokenAmount {
    init(string: String, denomination from: Denomination) throws {
        let numberFormatter: NumberFormatter = .default
        let decimalSeparator = Locale.decimalSeparatorIndeed
        
        func amountInAttoFromNonDecimalString(_ nonDecimalString: String, conversion: (PositiveAmount) -> PositiveAmount = { $0 }) throws -> PositiveAmount {
            assert(!nonDecimalString.contains(decimalSeparator))
            guard let bigSignedInt = BigSignedInt(nonDecimalString, radix: 10) else {
                throw Error.stringNotANumber(string)
            }
            guard bigSignedInt > .zero else {
                throw Error.amountMustBePositive
            }
            do {
                let positiveAmount = try PositiveAmount(validating: bigSignedInt.magnitude)
                return conversion(positiveAmount)
            } catch { unexpectedlyMissedToCatch(error: error) }
        }
        
        if let decimalSeparatorIndex = string.index(of: decimalSeparator) {
            let numberOfDecimals = string.distance(from: decimalSeparatorIndex, to: string.endIndex) - 1
            let exponentDelta = abs(Denomination.minAllowedExponent - from.exponent)
            
            if exponentDelta < numberOfDecimals {
                throw Error.amountFromStringNotRepresentableInDenomination(amountString: string, specifiedDenomination: from)
            } else {
                var amountMeasuredInAttoDroppedDecimals = try amountInAttoFromNonDecimalString(string.replacingOccurrences(of: decimalSeparator, with: ""))
                
                if exponentDelta > numberOfDecimals {
                    let exponent = exponentDelta - numberOfDecimals
                    let factor = BigUnsignedInt.init(integerLiteral: 10).power(exponent)
                    let correctAmount = amountMeasuredInAttoDroppedDecimals.magnitude.multiplied(by: factor)
                    amountMeasuredInAttoDroppedDecimals = PositiveAmount(validated: correctAmount)
                }
                
                self.amountMeasuredInAtto = amountMeasuredInAttoDroppedDecimals
            }
        } else {
            self.amountMeasuredInAtto = try amountInAttoFromNonDecimalString(string) {
                Self.convertToAtto(amount: $0, from: from)
            }
        }
    }
    
    @available(*, deprecated, message: "_NOT_ deprecated, but a word of caution: `Double` might lose precision after a certain amount of decimals, consider using `init(positiveAmount:denomination)` or `init(string:denomination)` (which this init delegates to anyway) instead")
    init(double: Double, denomination from: Denomination) throws {
        guard from.exponent > Denomination.minAllowedExponent else {
            throw Error.amountInAttoIsOnlyMeasuredInIntegers(butPassedDouble: double)
        }
        guard let numberString = NumberFormatter.default.string(from: NSNumber(value: double)) else {
            incorrectImplementationShouldAlwaysBeAble(to: "Format a number string from double value: \(double)")
        }
        try self.init(string: numberString, denomination: from)
    }
}

// MARK: - Throwing
extension TokenAmount: Throwing {}
public extension TokenAmount {
    enum Error: Swift.Error, Equatable {
        case stringNotANumber(String)
        case amountMustBePositive
        case amountInAttoIsOnlyMeasuredInIntegers(butPassedDouble: Double)
        case amountFromStringNotRepresentableInDenomination(amountString: String, specifiedDenomination: Denomination)
        case amountNotRepresentableAsIntegerInDenomination(amount: BigUnsignedInt, fromDenomination: Denomination, toDenomination: Denomination)
    }
}

// MARK: CustomStringConvertible
public extension TokenAmount {
    var description: String {
        return format(amount: amountMeasuredInAtto, denomination: .atto)
    }
    
    func display(in desiredDenomination: Denomination) throws -> String {
        let converted = try Self.convert(amount: amountMeasuredInAtto, from: .atto, to: desiredDenomination)
        return format(amount: converted, denomination: desiredDenomination)
    }
    
    func displayUsingHighestPossibleNamedDenominator() -> String {
        let (amount, denomination) = expressedInBiggestPossibleDenomination()
        return format(amount: amount, denomination: denomination)
    }
}

// MARK: - Conversion
public extension TokenAmount {
    
    static func convert<NNA>(
        amount: NNA,
        from: Denomination,
        to: Denomination
    ) throws -> NNA where NNA: NonNegativeAmountConvertible {
        
        let exponentDelta = abs(to.exponent - from.exponent)
        let magnitude = amount.magnitude
        let scale = BigUnsignedInt(10).power(exponentDelta)
        
        if from == to {
            return amount
        } else if from > to {
            return NNA.init(validated: magnitude.multiplied(by: scale))
        } else if from < to {
            let (quotient, remainder) = magnitude.quotientAndRemainder(dividingBy: scale)
            guard remainder == 0 else {
                throw Error.amountNotRepresentableAsIntegerInDenomination(
                    amount: magnitude,
                    fromDenomination: from,
                    toDenomination: to
                )
            }
            
            return NNA.init(validated: quotient)
        } else { incorrectImplementation("All cases should have been handled already.") }
    }
    
    func expressedInBiggestPossibleDenomination() -> (amount: PositiveAmount, denomination: Denomination) {
        
        for denomination in Denomination.allCases.sorted().reversed() {
            if let convertedAmount = try? Self.convert(amount: amountMeasuredInAtto, from: .atto, to: denomination) {
                return (amount: convertedAmount, denomination: denomination)
            }
        }
        return (amount: amountMeasuredInAtto, denomination: .atto)
    }
    
}

private extension TokenAmount {
    
    func format<NNA>(amount: NNA, denomination: Denomination) -> String where NNA: NonNegativeAmountConvertible {
        return "\(amount.magnitude) \(denomination.name) (\(denomination.exponentSuperscript))"
    }
    
    static func convertToAtto<NNA>(
        amount: NNA,
        from: Denomination
    ) -> NNA where NNA: NonNegativeAmountConvertible {
        do {
            return try convert(amount: amount, from: from, to: .atto)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Convert amount to denomination: '\(Denomination.atto)'", error)
        }
    }
}
