//
//  TokenParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//#if os(OSX)
//import AppKit.NSImage
//public typealias Image = NSImage
//#elseif os(iOS) || os(tvOS) || os(watchOS)
//import UIKit.UIImage
//public typealias Image = UIImage
//#endif
//
//#if os(iOS) || os(tvOS) || os(watchOS)
//import UIKit
//extension Image: DataConvertible {
//    public var asData: Data {
//        return UIImagePNGRepresentation(self)
//    }
//}
//
//extension Image: Codable {
//    public convenience init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        let data = try container.decode(Data.self)
//        guard UIImage(data: data) != nil else {
//            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to create UIImage from data")
//        }
//        self.init(data: data)!
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        let asData =
//        try container.encode(value)
//    }
//}
//#endif

public typealias Granularity = BigUnsignedInt

public struct TokenParticle: ParticleConvertible, CustomStringConvertible {
    public let quarks: Quarks
    
    public let name: String
    public let description: String
    public let granularity: Granularity
    public let iconData: Data
    public let tokenPermissions: [FungibleType: TokenPermission]
    
    public init(
        address: Address,
        name: String,
        symbol: String,
        description: String,
        granularity: Granularity,
        tokenPermissions: [FungibleType: TokenPermission],
        icon: Data
        ) {
        self.quarks = [
            IdentifiableQuark(identifier: ResourceIdentifier(address: address, type: .tokenClass, unique: symbol)),
            AccountableQuark(addresses: [address]),
            OwnableQuark(owner: address.publicKey)
        ]
        self.name = name
        self.description = description
        self.granularity = granularity
        self.tokenPermissions = tokenPermissions
        self.iconData = icon
    }
}

public extension TokenParticle {
    func tokenClassReference() -> TokenClassReference {
        return TokenClassReference(identifier: quarkOrCrash(type: IdentifiableQuark.self).identifier)
    }
}

// TODO should this be an optionset?
public enum TokenPermission: String, Codable {
    case pow = "POW"
    case genesisOnly = "GENESIS_ONLY"
    case sameAtomOnly = "SAME_ATOM_ONLY"
    case tokenOwnerOnly = "TOKEN_OWNER_ONLY"
    case all = "ALL"
    case none = "NONE"
}
