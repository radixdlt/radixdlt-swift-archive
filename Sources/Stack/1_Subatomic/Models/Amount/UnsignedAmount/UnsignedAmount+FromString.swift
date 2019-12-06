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

public extension UnsignedAmount {
    
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

