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
public struct Denomination: Hashable, CustomStringConvertible {
    
    /// The important value, the exponent to raise `10` to the power of, e.g. the decimal value of this denomination value is `10^{exponent}`
    public let exponent: Int
    
    public let name: String
    public let symbol: String
    
    public init(exponent: Int, name: String, symbol: String) throws {
        guard exponent >= Denomination.minAllowedExponent else {
            throw Error.exponentMustBeGreaterThanOrEqualTo(min: Denomination.minAllowedExponent)
        }
        
        self.exponent = exponent
        self.name = name
        self.symbol = symbol
    }
}

public extension Denomination {
    enum Error: Swift.Error, Equatable {
        case exponentMustBeGreaterThanOrEqualTo(min: Int)
    }
}

public extension Denomination {
    func hash(into hasher: inout Hasher) {
        hasher.combine(exponent)
    }
}

// swiftlint:disable colon comma

public extension Denomination {
    static var exa          : Self { .init(18, s: "E") }
    static var peta         : Self { .init(15, s: "P") }
    static var tera         : Self { .init(12, s: "T") }
    static var giga         : Self { .init(9,  s: "G") }
    static var mega         : Self { .init(6,  s: "M") }
    static var kilo         : Self { .init(3,  s: "k") }
    static var hecto        : Self { .init(2,  s: "h") }
    static var deca         : Self { .init(1,  s: "da") }
    
    /// This is the standard denomination of all UserActions.
    static var whole        : Self { .init(0,   s: "1") }
    
    static var deci         : Self { .init(-1,  s: "d") }
    static var centi        : Self { .init(-2,  s: "c") }
    static var milli        : Self { .init(-3,  s: "m") }
    static var micro        : Self { .init(-6,  s: "μ") }
    static var nano         : Self { .init(-9,  s: "n") }
    static var pico         : Self { .init(-12, s: "p") }
    static var femto        : Self { .init(-15, s: "f") }
    
    /// `atto` with an exponent of `-18` is the smallest possible denomination of Radix. The Radix Core / Radix Engine uses this in all `Particle`.
    /// In other words, in the end all amounts will be converted to `atto` and sent to the a Node's API.
    static var atto         : Self { .init(Denomination.minAllowedExponent, s: "a") }
    
    static let minAllowedExponent: Int = -18
    static let min: Self = .atto
}

// swiftlint:enable colon comma

private extension Denomination {
    init(_ exponent: Int, _ name: String = #function, s symbol: String) {
        do {
            try self.init(exponent: exponent, name: name, symbol: symbol)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Create preset denomination", error)
        }
    }
}

// MARK: CustomStringConvertible
public extension Denomination {
    var description: String {
        return name
    }
}

public extension Denomination {
    
    func expressValueInSmallestPossibleDenomination<M>(value: M) -> M where M: BinaryInteger {
        if exponent == Self.minAllowedExponent { return value }
        
        let exponentDelta: Int = abs(Self.minAllowedExponent - self.exponent)
        
        let factorInt = Int(pow(Double(10), Double(exponentDelta)))
        let factor = M(factorInt)
        return value * factor
    }
}

public extension Denomination {
    static func exponent(
        of exponent: Int,
        nameIfUnknown: String = "unknown",
        symbolIfUnknown: String = "?",
        ifUnknown: (Int, String, String) throws -> Denomination = { newExponent, newName, newSymbol in
            try Denomination(exponent: newExponent, name: newName, symbol: newSymbol)
        }
    ) rethrows -> Denomination {
        if let preset = Denomination.allCases.first(where: { $0.exponent == exponent }) {
            return preset
        }
        return try ifUnknown(exponent, nameIfUnknown, symbolIfUnknown)
    }
}
