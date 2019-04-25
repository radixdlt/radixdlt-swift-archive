//
//  UniverseConfig.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

public struct UniverseConfig:
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    RadixHashable,
    DSONEncodable,
    Decodable,
    Equatable,
    CustomStringConvertible {
    // swiftlint:enable colon
    
    public let magic: Magic
    public let port: Port
    public let name: String
    public let description: String
    public let type: UniverseType
    public let timestamp: Date
    public let creator: PublicKey
    public let genesis: Atoms
    public let planck: Planck
    
    /// Only used for tests
    internal let hashIdFromApiUsedForTesting: EUID?
}

// MARK: - Decodable
public extension UniverseConfig {
    
    enum CodingKeys: String, CodingKey {
        case serializer, version
        case magic, port, name, description, type, timestamp, creator, genesis, planck
        
        // TEST ONLY
        case hashIdFromApiUsedForTesting = "hid"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        magic = try container.decode(Magic.self, forKey: .magic)
        port = try container.decode(Port.self, forKey: .port)
        name = try container.decode(StringValue.self, forKey: .name).stringValue
        description = try container.decode(StringValue.self, forKey: .description).stringValue
        type = try container.decode(UniverseType.self, forKey: .type)
        let timestampMillis = try container.decode(TimeInterval.self, forKey: .timestamp)
        timestamp = TimeConverter.dateFrom(millisecondsSince1970: timestampMillis)
        creator = try container.decode(PublicKey.self, forKey: .creator)
        genesis = try container.decode(Atoms.self, forKey: .genesis)
        
        planck = try container.decode(Planck.self, forKey: .planck)
        
        // TESTING ONLY
        hashIdFromApiUsedForTesting = try container.decodeIfPresent(EUID.self, forKey: .hashIdFromApiUsedForTesting)
    }
}

// MARK: Encodable
public extension UniverseConfig {
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .magic, value: magic, output: .allButHash),
            EncodableKeyValue(key: .planck, value: planck),
            EncodableKeyValue(key: .port, value: port),
            EncodableKeyValue(key: .name, value: name),
            EncodableKeyValue(key: .description, value: description),
            EncodableKeyValue(key: .timestamp, value: TimeConverter.millisecondsFrom(date: timestamp)),
            EncodableKeyValue(key: .creator, value: creator),
            EncodableKeyValue(key: .type, value: type),
            EncodableKeyValue(key: .genesis, value: genesis)
        ]
    }
}

// MARK: - RadixModelTypeStaticSpecifying
public extension UniverseConfig {
    static let serializer: RadixModelType = .universeConfig
}

public extension UniverseConfig {
    var magicByte: Byte {
        return magic.byte
    }
}

