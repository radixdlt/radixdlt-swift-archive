//
//  Signature.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Signature: Equatable, Codable {
    public typealias SignaturePart = BigUnsignedInt
    public let r: SignaturePart
    public let s: SignaturePart
    
    // MARK: These properties are need in ordet to assure correct hash
    public let serializer = RadixModelType.signature.rawValue
    public let version = dataFormatVersion
}

// MARK: - Decodable
public extension Signature {
    
    public enum CodingKeys: CodingKey {
        case r, s
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        r = try container.decode(Base64String.self, forKey: .r).unsignedBigInteger
        s = try container.decode(Base64String.self, forKey: .s).unsignedBigInteger
    }
}

// MARK: - Encodable
public extension Signature {
    func encode(to encoder: Encoder) throws {
        implementMe
    }
}
