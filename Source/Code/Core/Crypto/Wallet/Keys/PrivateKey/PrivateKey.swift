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
    Signing,
    Equatable {
    // swiftlint:enable colon
    public typealias Scalar = BigUnsignedInt
    public let scalar: Scalar
    
    public init(scalar: Scalar) throws {
        if scalar == 0 {
            throw Error.mustBeGreaterThanZero
        }
        if scalar >= Secp256k1.order {
            throw Error.mustBeSmallerThanCurveOrder
        }
        self.scalar = scalar
    }
    
    public static func generateNew() -> PrivateKey {
        let byteCount = 32
        var privateKey: PrivateKey!
        repeat {
            guard let randomData = try? securelyGenerateBytes(count: byteCount) else { continue }
            privateKey = try? PrivateKey(data: randomData)
        } while privateKey == nil
        return privateKey
    }
    
    public init() {
        self = PrivateKey.generateNew()
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

// MARK: - WIF
public extension PrivateKey {
    init(wif: Base58String) throws {
        let bitcoinKitPrivateKey = try BitcoinKit.PrivateKey(wif: wif.stringValue)
        try self.init(data: bitcoinKitPrivateKey.data)
    }
 }

// MARK: - ExpressibleByStringLiteral
public extension PrivateKey {
    /// Accepts a hexadecimal string
    init(string hexString: String) throws {
        try self.init(hex: hexString)
    }
    
    init(hex hexString: String) throws {
        let scalar = try Scalar(hexString: hexString)
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

// MARK: - Signing
public extension PrivateKey {
    var privateKey: PrivateKey {
        return self
    }
}

// MARK: - BitcoinKit
import BitcoinKit
internal extension PrivateKey {

    var bitcoinKitPrivateKey: BitcoinKit.PrivateKey {
        return BitcoinKit.PrivateKey(data: asData, network: BitcoinKit.Network.mainnetBTC, isPublicKeyCompressed: true)
    }
}
