//
//  Amount.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// Base protocol for `PositiveAmount` and `SignedAmount`
public protocol Amount:
    PrefixedJsonCodable,
    StringRepresentable,
    CBORDataConvertible,
    Numeric,
    Comparable
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
        self.init(validated: fromSource)
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
        try self.init(validating: try Magnitude(string: string))
    }
}

// MARK: - StringRepresentable
public extension Amount {
    var stringValue: String {
        return magnitude.stringValue
    }
}

// MARK: - PrefixedJsonDecodable
public extension Amount {
    static var jsonPrefix: JSONPrefix { return .uint256DecimalString }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Amount {
    init(integerLiteral: Magnitude.IntegerLiteralType) {
        let unvalidatedMagnitude = Magnitude.init(integerLiteral: integerLiteral)
        self.init(validated: unvalidatedMagnitude)
    }
}

// MARK: - CustomStringConvertible
public extension Amount {
    var description: String {
        return stringValue
    }
}
