//
//  Granularity.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// The smallest non-divisible amount of subunits one can have is introduced. For the formal definition read [RIP - Tokens][1].
///
/// - seeAlso:
/// `TokenDefinitionParticle`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/407241467/RIP-2+Tokens
///
public struct Granularity:
    PrefixedJsonCodable,
    CBORDataConvertible,
    StringRepresentable,
    Comparable,
    Hashable,
    CustomStringConvertible
{

// swiftlint:enable colon opening_brace
    
    public typealias Value = PositiveAmount
    
    public let value: Value

    public init(value: PositiveAmount) throws {
        if value > Granularity.subunitsDenominator {
            throw Error.tooLarge(expectedAtMost: Granularity.subunitsDenominator, butGot: value)
        }
        self.value = value
    }
}

public extension Granularity {
    
    // MARK: - Subunits
    static var subunitsDenominatorDecimalExponent: Int { return 18 }
    static var subunitsDenominator: PositiveAmount {
        let magnitude = PositiveAmount.Magnitude(10).power(Granularity.subunitsDenominatorDecimalExponent)
        return PositiveAmount(validated: magnitude)
    }
    static let max: Granularity = {
        // swiftlint:disable:next force_try
        return try! Granularity(value: subunitsDenominator)
    }()
    
    static let one: Granularity = {
        // swiftlint:disable:next force_try
        return try! Granularity(int: 1)
    }()
    
    static let min = Granularity.one
}

public extension Granularity {
    init(magnitude: PositiveAmount.Magnitude) throws {
        do {
            let positiveAmount = try PositiveAmount(validating: magnitude)
            try self.init(value: positiveAmount)
        } catch PositiveAmount.Error.amountCannotBeZero {
            throw Error.cannotBeZero
        } catch {
            throw error
        }
    }
    
    init(int: UInt) throws {
        let magnitude = PositiveAmount.Magnitude(int)
        try self.init(magnitude: magnitude)
    }
}

// MARK: Comparable
public extension Granularity {
    static func < (lhs: Granularity, rhs: Granularity) -> Bool {
        return lhs.value < rhs.value
    }
}

// MARK: DSONPrefixSpecifying
public extension Granularity {
    var dsonPrefix: DSONPrefix {
        return .unsignedBigInteger
    }
}

// MARK: - DataConvertible
public extension Granularity {
    var asData: Data {
        return value.toHexString(case: .lower, mode: .minimumLength(64, .prepend)).asData
    }
}

// MARK: - StringInitializable
public extension Granularity {
    init(string: String) throws {
        let decimalString = try DecimalString(unvalidated: string)
        let value = try PositiveAmount(string: decimalString.stringValue)
        try self.init(value: value)
    }
}

// MARK: - StringRepresentable
public extension Granularity {
    var stringValue: String {
        return decimalString
    }
    
}

public extension Granularity {
    var decimalString: String {
        return value.magnitude.toDecimalString()
    }
}
    
// MARK: - PrefixedJsonDecodable
public extension Granularity {
    static let jsonPrefix = JSONPrefix.uint256DecimalString
}

// MARK: - CustomStringConvertible
public extension Granularity {
    var description: String {
        return stringValue
    }
}

// MARK: - Error
public extension Granularity {
    enum Error: Swift.Error, Equatable {
        case cannotBeZero
        case tooLarge(expectedAtMost: PositiveAmount, butGot: PositiveAmount)
        case failedToCreateBigInt(fromString: String)
    }
}

// MARK: - Presets
public extension Granularity {
    static let `default` = Granularity.one
}
