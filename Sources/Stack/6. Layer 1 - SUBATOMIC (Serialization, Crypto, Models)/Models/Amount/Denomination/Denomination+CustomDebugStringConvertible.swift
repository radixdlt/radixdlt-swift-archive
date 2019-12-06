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

extension Denomination: CustomDebugStringConvertible {}
public extension Denomination {
    
    var debugDescription: String {
        return [
            String(describing: exponent),
            name,
            symbol,
            exponentSuperscript,
            String(describing: decimalValue)
        ].joined(separator: " | ")
    }
    
    var exponentSuperscript: String {
        return "10\(exponent.superscriptString())"
    }
    
    var decimalValue: Decimal {
        do {
            return try Decimal.ten(toThePowerOf: exponent)
        } catch { incorrectImplementationShouldAlwaysBeAble(to: "Calculate decimal of denomination", error) }
    }
}

extension Int {
    
    func superscriptString() -> String {
        let minusPrefixOrEmpty: String = self < 0 ? Superscript.minus : ""
        let (quotient, remainder) = abs(self).quotientAndRemainder(dividingBy: 10)
        let quotientString = quotient > 0 ? quotient.superscriptString() : ""
        return minusPrefixOrEmpty + quotientString + Superscript.value(remainder)
    }
}

enum Superscript {
    static let minus = "⁻"
    private static let values: [String] = [
        "⁰",
        "¹",
        "²",
        "³",
        "⁴",
        "⁵",
        "⁶",
        "⁷",
        "⁸",
        "⁹"
    ]
    
    static func value(_ int: Int) -> String {
        assert(int >= 0 && int <= 9)
        return values[int]
    }
}
