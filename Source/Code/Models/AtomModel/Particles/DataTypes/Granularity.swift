//
//  Granularity.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

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
    Equatable,
    ExpressibleByIntegerLiteral {
// swiftlint:enable colon
    
    public typealias Value = BigUnsignedInt
    
    public let value: Value

    public init(value: Value) {
        self.value = value
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
        guard let value = Value(string, radix: 10) else {
            throw Error.failedToCreateBigInt(fromString: string)
        }
        self.init(value: value)
    }
}

// MARK: - StringRepresentable
public extension Granularity {
    var stringValue: String {
        return value.toDecimalString()
    }
}

// MARK: - PrefixedJsonDecodable
public extension Granularity {
    static let jsonPrefix = JSONPrefix.uint256DecimalString
}

// MARK: - ExpressibleByIntegerLiteral
public extension Granularity {
    init(integerLiteral int: Int) {
        self.init(value: Value(int))
    }
}

// MARK: - CustomStringConvertible
public extension Granularity {
    var description: String {
        return value.description
    }
}

// MARK: - Error
public extension Granularity {
    enum Error: Swift.Error {
        case failedToCreateBigInt(fromString: String)
    }
}

// MARK: - Presets
public extension Granularity {
    static var `default`: Granularity {
        return 1
    }
}
