/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

// swiftlint:disable colon

/// Elliptic Curve Private Key
public struct PrivateKey:
    DataInitializable,
    DataConvertible,
    StringInitializable,
    Signing,
    Equatable,
    CustomDebugStringConvertible {
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

// MARK: - CustomDebugStringConvertible
public extension PrivateKey {
    var debugDescription: String {
        return asData.hex
    }
}

// MARK: - BitcoinKit
import BitcoinKit
internal extension PrivateKey {

    var bitcoinKitPrivateKey: BitcoinKit.PrivateKey {
        return BitcoinKit.PrivateKey(data: asData, network: BitcoinKit.Network.mainnetBTC, isPublicKeyCompressed: true)
    }
}
