//
//  UniverseConfig.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias Magic = Int64

public struct UniverseConfig: Codable, CustomStringConvertible, DSONDecodable {
    public let magic: Magic
    public let port: Int64
    public let name: String
    public let description: String
    public let type: UniverseType
    public let timestamp: Date
    public let creator: PublicKey
    public let genesis: Atoms
}

public extension UniverseConfig {
    var magicByte: Byte {
        let and = magic & Magic(bitPattern: 0xFF)
        return and.asData[0]
    }
}

public extension UniverseConfig {
    public enum UniverseType: Int, Codable {
        case `public` = 1
        case development
        
        public enum CodingKeys: String, CodingKey {
            case `public` = "RADIX_PUBLIC"
            case development = "RADIX_DEVELOPMENT"
        }
        
        var ordinalValue: Int {
            return rawValue
        }
        
        var name: String {
            switch self {
            case .public: return CodingKeys.public.rawValue
            case .development: return CodingKeys.development.rawValue
            }
        }
    }
}
