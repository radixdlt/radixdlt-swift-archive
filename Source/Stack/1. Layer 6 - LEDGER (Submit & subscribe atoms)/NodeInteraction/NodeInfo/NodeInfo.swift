//
//  NodeInfo.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// In Java library called `NodeRunnerData`
public struct NodeInfo:
    RadixModelTypeStaticSpecifying,
    Decodable,
    Hashable
{
    // swiftlint:enable colon opening_brace
    
    public let host: Host
    public let system: RadixSystem
    
    public init(host: Host, system: RadixSystem) {
        self.host = host
        self.system = system
    }
}

// MARK: - Equatable
public extension NodeInfo {
    func hash(into hasher: inout Hasher) {
        hasher.combine(host.domain)
        hasher.combine(system.shards)
    }
}

// MARK: - Equatable
public extension NodeInfo {
    static func == (lhs: NodeInfo, rhs: NodeInfo) -> Bool {
        return lhs.host.domain == rhs.host.domain && lhs.system.shards == rhs.system.shards
    }
}

// MARK: - Decodable
public extension NodeInfo {
    
    enum CodingKeys: String, CodingKey {
        case host
        case system
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.host = try container.decode(Host.self, forKey: .host)
        self.system = try container.decode(RadixSystem.self, forKey: .system)
    }
}

// MARK: - RadixModelTypeStaticSpecifying
public extension NodeInfo {
    static let serializer: RadixModelType = .nodeInfo
}
