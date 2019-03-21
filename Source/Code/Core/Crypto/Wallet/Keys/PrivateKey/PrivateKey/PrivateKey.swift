//
//  PrivateKey.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// Elliptic Curve Private Key
public struct PrivateKey:
    DataInitializable,
    DataConvertible,
    StringInitializable,
    Equatable {
    // swiftlint:enable colon

    private let scalar: BigUnsignedInt
    
    public init(scalar: BigUnsignedInt) throws {
        if scalar == 0 {
            throw Error.mustBeGreaterThanZero
        }
        if scalar >= Secp256k1.order {
            throw Error.mustBeSmallerThanCurveOrder
        }
        self.scalar = scalar
    }
    
    public enum Error: Swift.Error {
        case mustBeGreaterThanZero
        case mustBeSmallerThanCurveOrder
    }
}

// MARK: - DataInitializable
public extension PrivateKey {
    init(data: Data) throws {
        try self.init(scalar: data.unsignedBigInteger)
    }
}

// MARK: - ExpressibleByStringLiteral
public extension PrivateKey {
    /// Accepts a hexadecimal string
    init(string hexString: String) throws {
        let scalar = try BigUnsignedInt(hexString: hexString)
        try self.init(scalar: scalar)
    }
}

// MARK: - ExpressibleByIntegerLiteral
/* For testing only. Do NOT use Int64 to create a private key */
extension PrivateKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        guard isDebug else {
            incorrectImplementation("Do NOT use an Int to initialize a private key, that is not secure!")
        }
        do {
            try self.init(scalar: BigUnsignedInt(value))
        } catch {
            incorrectImplementation("Bad value sent, error: \(error)")
        }
    }
}

// MARK: - DataConvertible
public extension PrivateKey {
    var asData: Data {
        return scalar.toHexString(mode: StringConversionMode.minimumLength(64, .prepend)).asData
    }
}

// MARK: - BitcoinKit
import BitcoinKit
internal extension PrivateKey {
    var bitcoinKitPrivateKey: BitcoinKit.PrivateKey {
        return BitcoinKit.PrivateKey(data: asData, network: BitcoinKit.Network.mainnetBTC, isPublicKeyCompressed: true)
    }
}
