//
//  UniverseConfig.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias Magic = Int64

// swiftlint:disable colon

public struct UniverseConfig:
    RadixModelTypeStaticSpecifying,
    Decodable,
    Equatable,
    CustomStringConvertible {
    // swiftlint:enable colon
    
    public let magic: Magic
    public let port: Int64
    public let name: String
    public let description: String
    public let type: UniverseType
    public let timestamp: Date
    public let creator: PublicKey
    public let genesis: Atoms
}

// MARK: - RadixModelTypeStaticSpecifying
public extension UniverseConfig {
    static let type: RadixModelType = .universeConfig
}

public extension UniverseConfig {
    var magicByte: Byte {
        let and = magic & Magic(bitPattern: 0xFF)
        return and.asData[0]
    }
}

public extension UniverseConfig {
    enum UniverseType: Int, Decodable, Equatable {
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

public extension UniverseConfig {
    static var betanet: UniverseConfig {
        return config(fromResource: "betanet")
    }
    static var sunstone: UniverseConfig {
        return config(fromResource: "sunstone")
    }
}

private extension UniverseConfig {
    static func config(fromResource resource: String) -> UniverseConfig {
        guard
            let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
                incorrectImplementation("Config file not found: \(resource)")
        }
        do {
            let data = try Data(contentsOf: url)
            return try
                JSONDecoder().decode(UniverseConfig.self, from: data)
        } catch {
            incorrectImplementation("Failed to create config from data, error: \(error)")
        }
    }
}
