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

// swiftlint:disable colon opening_brace

/// Base protocol for `PositiveAmount` and `SignedAmount`
public protocol Amount:
    PrefixedJSONCodable,
    StringRepresentable,
    CBORDataConvertible,
    Numeric,
    Comparable,
    CustomStringConvertible
where
    Magnitude: BigInteger & StringRepresentable & StringInitializable
{
    // swiftlint:enable colon opening_brace

    var magnitude: Magnitude { get }
    
    init(validated: Magnitude)
    init(validating: Magnitude) throws
    
    var sign: AmountSign { get } 
    func negated() -> SignedAmount
    var abs: NonNegativeAmount { get }
}

// MARK: - Default
public extension Amount {
    init(validating valid: Magnitude) throws {
        self.init(validated: valid)
    }
}

// MARK: - Numeric Init
public extension Amount {
    
    init?<T>(exactly source: T) where T: BinaryInteger {
        guard let fromSource = Magnitude(exactly: source) else { return nil }
        try? self.init(validating: fromSource)
    }
}

// MARK: - Numeric Operators
public extension Amount {
    
    /// Multiplies two values and produces their product.
    static func * (lhs: Self, rhs: Self) -> Self {
        return calculate(lhs, rhs, operation: *)
    }
    
    /// Adds two values and produces their sum.
    static func + (lhs: Self, rhs: Self) -> Self {
        return calculate(lhs, rhs, operation: +)
    }
    
    /// Subtracts one value from another and produces their difference.
    static func - (lhs: Self, rhs: Self) -> Self {
        return calculate(lhs, rhs,
                         willOverflowIf: lhs is UnsignedNumeric && rhs > lhs,
                         operation: -)
    }
}

// MARK: - Numeric Operators Inout
public extension Amount {
    
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
public func * <A>(spin: Spin, amount: A) -> SignedAmount where A: Amount {
    switch spin {
    case .down, .neutral: return amount.negated()
    case .up: return SignedAmount(validated: SignedAmount.Magnitude(amount.magnitude))
    }
}

// MARK: - Private Helper
private extension Amount {
    
    static func calculate(
        _ lhs: Self,
        _ rhs: Self,
        willOverflowIf overflowCheck: @autoclosure () -> Bool = { false }(),
        operation: (Magnitude, Magnitude) -> Magnitude
    ) -> Self {
        precondition(overflowCheck() == false, "Overflow")
        return Self(validated: operation(lhs.magnitude, rhs.magnitude))
    }
    
}

// MARK: - Comparable
public extension Amount {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.magnitude < rhs.magnitude
    }
    static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.magnitude > rhs.magnitude
    }
}

// MARK: DSONPrefixSpecifying
public extension Amount {
    var dsonPrefix: DSONPrefix {
        return .unsignedBigInteger
    }
}

// MARK: - DataConvertible
public extension Amount {
    var asData: Data {
        return magnitude.toData(minByteCount: 32)
    }
}

// MARK: - StringInitializable
public extension Amount {
    init(string: String) throws {
        let magnitude = try Magnitude.init(string: string)
        try self.init(validating: magnitude)
    }
}

// MARK: - StringRepresentable
public extension Amount {
    var stringValue: String {
        return magnitude.stringValue
    }
}

// MARK: - PrefixedJSONDecodable
public extension Amount {
    static var jsonPrefix: JSONPrefix { return .uint256DecimalString }
}

// MARK: - From Binary Integer
public extension Amount {
    init<Integer>(integer: Integer) throws where Integer: BinaryInteger {
        try self.init(validating: Magnitude(integer))
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Amount {
    init(integerLiteral magnitudeIntegerLiteral: Magnitude.IntegerLiteralType) {
        do {
            try self.init(validating: Magnitude.init(integerLiteral: magnitudeIntegerLiteral))
        } catch {
            badLiteralValue(magnitudeIntegerLiteral, error: error)
        }
    }
}

// MARK: - CustomStringConvertible
public extension Amount {
    var description: String {
        return amountAndSign.description
    }
}
