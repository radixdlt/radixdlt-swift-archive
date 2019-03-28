//
//  Signature.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// ECDSA Signature consisting of two BigIntegers "R" and "S"
/// Read more: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
/// Low value `S` is enforced according to BIP62: https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki#Low_S_values_in_signatures
public struct Signature:
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    DataConvertible,
    ExactLengthSpecifying,
    StringInitializable,
    DERConvertible,
    DERInitializable,
    Codable,
    Equatable {
// swiftlint:enable colon
    
    public static let length = 64
    
    public static let serializer = RadixModelType.signature
    
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
        guard r <= Signature.rUpperBound else {
            throw Error.rTooBig(expectedAtMost: Signature.rUpperBound, butGot: r)
        }
        guard r > 0 else {
            throw Error.rCannotBeZero
        }
        guard s <= Signature.sUpperBound else {
            throw Error.sTooBig(expectedAtMost: Signature.sUpperBound, butGot: s)
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

// MARK: - DataInitializable
public extension Signature {
    init(data: Data) throws {
        try Signature.validateLength(of: data)
        let byteCount = Signature.length / 2
        let rData = Data(data.prefix(byteCount))
        let sData = Data(data.suffix(byteCount))
        try self.init(
            r: rData.unsignedBigInteger,
            s: sData.unsignedBigInteger
        )
    }
}

// MARK: - DERInitializable
public extension Signature {
    init(der: DER) throws {
        try self.init(data: der.decoded())
    }
}

// MARK: - StringInitializable
public extension Signature {
    init(string: String) throws {
        let hexString = try HexString(string: string)
        try self.init(data: hexString.asData)
    }
}

// MARK: - DataConvertible
public extension Signature {
    var asData: Data {
        return r.asData + s.asData
    }
}

// MARK: - DERConvertible
public extension Signature {
    func toDER() throws -> DER {
        return DER(signature: self)
    }
}

// MARK: - Decodable
public extension Signature {
    
    enum CodingKeys: String, CodingKey {
        case serializer
        case r, s
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let rBase64 = try container.decode(Base64String.self, forKey: .r)
        let sBase64 = try container.decode(Base64String.self, forKey: .s)
        
         // TODO: When Java library ensures low value S we should call the designated initializer in order to perform validation
//        try self.init(r: rBase64, s: sBase64)
        self.r = rBase64.unsignedBigInteger
        self.s = sBase64.unsignedBigInteger
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
