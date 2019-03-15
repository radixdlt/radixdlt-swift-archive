//
//  Amount.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Amount: PrefixedJsonCodable, StringRepresentable, CBORDataConvertible, Equatable, ExpressibleByIntegerLiteral {
    
    public static let subunitsDenominatorDecimalExponent: Int = 18
    public static let subunitsDenominator = BigUnsignedInt(10).power(Amount.subunitsDenominatorDecimalExponent)

    public typealias Value = BigUnsignedInt
    
    public let value: Value
    
    public init(value: Value) {
        self.value = value
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
        return value.toData(minByteCount: 32)
    }
}

// MARK: - StringInitializable
public extension Amount {
    init(string: String) throws {
        guard let value = Value(string, radix: 10) else {
            if string.starts(with: "-") {
                throw Error.cannotBeNegative
            } else {
                throw Error.failedToCreateBigInt(fromString: string)
            }
        }
        self.init(value: value)
    }
}

// MARK: - StringRepresentable
public extension Amount {
    var stringValue: String {
        return value.toDecimalString()
    }
}

// MARK: - PrefixedJsonDecodable
public extension Amount {
    static let jsonPrefix = JSONPrefix.uint256DecimalString
}

// MARK: - ExpressibleByIntegerLiteral
public extension Amount {
    init(integerLiteral int: Int) {
        self.init(value: Value(int))
    }
}

// MARK: - CustomStringConvertible
public extension Amount {
    var description: String {
        return value.description
    }
}

// MARK: - Error
public extension Amount {
    public enum Error: Swift.Error {
        case cannotBeNegative
        case failedToCreateBigInt(fromString: String)
    }
}
