//
//  Signature.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//extension BigUnsignedInt: DataConvertible {
//    public var asData: Data {
//        return toData()
//    }
//}

public struct Secp256k1 {}
public extension Secp256k1 {
    static let order = BigUnsignedInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
}

/// ECDSA Signature consisting of two BigIntegers "R" and "S"
/// Read more: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
/// Low value `S` is enforced according to BIP62: https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki#Low_S_values_in_signatures
public struct Signature: Equatable, AtomModelConvertible {
    
    public static let type = RadixModelType.signature
    
    public typealias Part = BigUnsignedInt
    
    public static let rUpperBound = Secp256k1.order - 1
    /// Ensures "low S"
    public static let sUpperBound = Secp256k1.order / 2
    
    public let r: Part
    public let s: Part
    
    // MARK: These properties are need in ordet to assure correct hash
    public let serializer = RadixModelType.signature.rawValue
    public let version = dataFormatVersion
    
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
    
    public enum CodingKeys: String, RadixModelKey {
        public static let modelType = CodingKeys.type
        case type = "serializer"
        case r, s
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try Signature.verifyType(container: container)
        
        let rBase64 = try container.decode(Base64String.self, forKey: .r)
        let sBase64 = try container.decode(Base64String.self, forKey: .s)
        try self.init(r: rBase64, s: sBase64)
    }
}

// MARK: - Encodable
public extension Signature {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        let length = 32
        try container.encode(r.toBase64String(minLength: length), forKey: .r)
        try container.encode(s.toBase64String(minLength: length), forKey: .s)
    }
}
