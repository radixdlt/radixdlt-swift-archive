//
//  Signature.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Secp256k1 {}
public extension Secp256k1 {
    static let order = BigUnsignedInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
}

// swiftlint:disable colon

/// ECDSA Signature consisting of two BigIntegers "R" and "S"
/// Read more: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
/// Low value `S` is enforced according to BIP62: https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki#Low_S_values_in_signatures
public struct Signature:
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    Equatable {
// swiftlint:enable colon
    
    public static let type = RadixModelType.signature
    
    public typealias Part = BigUnsignedInt
    
    public static let rUpperBound = Secp256k1.order - 1
    /// Ensures "low S"
    public static let sUpperBound = Secp256k1.order / 2
    
    public let r: Part
    public let s: Part
    
    public enum Error: Swift.Error {
        case rTooBig(expectedAtMost: BigUnsignedInt, butGot: BigUnsignedInt)
        case sTooBig(expectedAtMost: BigUnsignedInt, butGot: BigUnsignedInt)
        case rCannotBeZero
        case sCannotBeZero
    }
    
    public init(r: Part, s: Part) throws {
        guard s <= Signature.sUpperBound else {
            throw Error.sTooBig(expectedAtMost: Signature.sUpperBound, butGot: s)
        }
        guard r <= Signature.rUpperBound else {
            throw Error.rTooBig(expectedAtMost: Signature.rUpperBound, butGot: r)
        }
        guard r > 0 else {
            throw Error.rCannotBeZero
        }
        guard s > 0 else {
            throw Error.sCannotBeZero
        }
        self.r = r
        self.s = s
    }
    
    public init(r: Base64String, s: Base64String) throws {
        try self.init(r: r.unsignedBigInteger, s: s.unsignedBigInteger)
    }
}

// MARK: - Decodable
public extension Signature {
    
    public enum CodingKeys: String, CodingKey {
        case type = "serializer"
        case r, s
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let rBase64 = try container.decode(Base64String.self, forKey: .r)
        let sBase64 = try container.decode(Base64String.self, forKey: .s)
        try self.init(r: rBase64, s: sBase64)
    }
}

// MARK: - Encodable
public extension Signature {
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        let length = 32
        return [
            EncodableKeyValue(key: .r, value: r.toBase64String(minLength: length)),
            EncodableKeyValue(key: .s, value: s.toBase64String(minLength: length))
        ]
    }
}
