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

/// The different denominations of Radix, only the `exponent` value is used for equals and comparison.
///
/// Defining common denominations, see [list on wiki][1]
///
/// [1]: https://en.wikipedia.org/wiki/Metric_prefix#List_of_SI_prefixes
///
public struct Denomination: Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    
    /// The important value, the exponent to raise `10` to the power of, e.g. the decimal value of this denomination value is `10^{exponent}`
    public let exponent: Int

    public let prefix: String
    public let symbol: String
    private let superscript: String
    public let englishWord: EnglishWord
    
    public init(exponent: Int, prefix: String, symbol: String, superscript: String, englishWord: EnglishWord) {
        self.exponent = exponent
        self.prefix = prefix
        self.symbol = symbol
        self.superscript = superscript
        self.englishWord = englishWord
    }
}

private extension Denomination {
    init(_ exponent: Int, p prefix: String, s symbol: String, _ superscript: String, _ englishWord: EnglishWord) {
        self.init(exponent: exponent, prefix: prefix, symbol: symbol, superscript: superscript, englishWord: englishWord)
    }
}

public extension Denomination {
    var description: String {
        return prefix
    }
    
    var debugDescription: String {
        return [
            String(describing: exponent),
            prefix,
            symbol,
            "10\(self.superscript)",
//            String(describing: decimalValue),
            String(describing: englishWord)
        ].joined(separator: " | ")
    }
    
    var decimalValue: Decimal {
        return NSDecimalNumber(value: 10).raising(toPower: exponent).decimalValue
    }
}

public extension Denomination {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return compare(lhs, rhs, keyPath: \.exponent, ==)
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        return compare(lhs, rhs, keyPath: \.exponent, <)
    }
    
    static func > (lhs: Self, rhs: Self) -> Bool {
        return compare(lhs, rhs, keyPath: \.exponent, >)
    }
}

public extension Comparable {
    static func compare<C>(_ lhs: Self, _ rhs: Self, keyPath: KeyPath<Self, C>, _ comparison: (C, C) -> Bool) -> Bool where C: Comparable {
        let lhsValue = lhs[keyPath: keyPath]
        let rhsValue = rhs[keyPath: keyPath]
        return comparison(lhsValue, rhsValue)
     }
}

struct Superscript {
    let minus: String = "⁻"
    let zero = "⁰"
    let one = "¹"
    let two = "²"
    let three = "³"
    let four = "⁴"
    let five = "⁵"
    let six = "⁶"
    let seven = "⁷"
    let eight = "⁸"
    let nine = "⁹"
}

// swiftlint:disable comma identifier_name

private let S = Superscript()

/// Superscript minus followed by whatever value passed as KeyPath
private func n(_ keyPath: KeyPath<Superscript, String>) -> String {
    return S.minus + S[keyPath: keyPath]
}

/// Superscript minus followed by `1` and whatever value passed as KeyPath
private func nOne(_ keyPath: KeyPath<Superscript, String>) -> String {
    return S.minus + S.one + S[keyPath: keyPath]
}

private func pOne(_ keyPath: KeyPath<Superscript, String>) -> String {
    return S.one + S[keyPath: keyPath]
}

public extension Denomination {
    static let tera         = Self(12,  p: "tera", s: "T",   pOne(\.two), .scales(short: "trillion", long: "billion"))
    static let giga         = Self(9,   p: "giga",  s: "G",  S.nine,      .scales(short: "billion", long: "milliard"))
    static let mega         = Self(6,   p: "mega",  s: "M",  S.six,       .just("million"))
    static let kilo         = Self(3,   p: "kilo",  s: "k",  S.three,     .just("thousand"))
    static let hecto        = Self(2,   p: "hecto", s: "h",  S.two,       .just("hundred"))
    static let deca         = Self(1,   p: "deca",  s: "da", S.one,       .just("ten"))
    
    /// The denomination used by the Radix Core / Radix Engine, .e.g the unit used in all `Particle`'s.
    static let wholeUnit    = Self(0,   p: "whole", s: "1",  S.zero,      .just("one"))

    static let deci         = Self(-1,  p: "deci",  s: "d",  n(\.one),    .just("tenth"))
    static let centi        = Self(-2,  p: "centi", s: "c",  n(\.two),    .just("hundredth"))
    static let milli        = Self(-3,  p: "milli", s: "m",  n(\.three),  .just("thousandth"))
    static let micro        = Self(-6,  p: "micro", s: "μ",  n(\.six),    .just("millionth"))
    static let nano         = Self(-9,  p: "nano",  s: "n",  n(\.nine),   .scales(short: "billionth", long: "milliardth"))
    static let pico         = Self(-12, p: "pico",  s: "p",  nOne(\.two), .scales(short: "trillionth", long: "billionth"))
    static let femto        = Self(-15, p: "femto", s: "f",  nOne(\.five),.scales(short: "quadrillionth", long: "billiardth"))

    /// `atto` with an exponent of `-18` is the smallest possible denomination of Radix. All UserActions are using this
    static let atto         = Self(-18, p: "atto",  s: "a", nOne(\.eight),.scales(short: "quintillionth", long: "trillionth"))

}

// swiftlint:enable comma identifier_name type_name

public extension Denomination {
    enum EnglishWord: CustomStringConvertible {
        case just(String)
        case scales(short: String, long: String)
    }
}

public extension Denomination.EnglishWord {
    var description: String {
        switch self {
        case .just(let single):
            return single
        case .scales(let shortScale, let longScale):
            return [shortScale, longScale].joined(separator: "|")
        }
    }
}
