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
    
    public let system: RadixSystem
    public let host: Host?
    
    public init(system: RadixSystem, host: Host?) {
        self.system = system
        self.host = host
    }
}

// MARK: - Equatable
public extension NodeInfo {
    func hash(into hasher: inout Hasher) {
        if let host = host {
            hasher.combine(host.domain)
        }
        hasher.combine(system.shardSpace)
    }
}

// MARK: - Equatable
public extension NodeInfo {
    static func == (lhs: NodeInfo, rhs: NodeInfo) -> Bool {
        guard lhs.system.shardSpace == rhs.system.shardSpace else { return false }
        
        let maybeLhsHost = lhs.host
        let maybeRhsHost = rhs.host
        switch (maybeLhsHost, maybeRhsHost) {
        case (.some(let lhsHost), .some(let rhsHost)): return lhsHost == rhsHost
        case (.none, .none): return true
        default: return false
        }
    }
}

public extension NodeInfo {
    var shardSpace: ShardSpace {
        return system.shardSpace
    }
}

// MARK: - Decodable
public extension NodeInfo {
    
    enum CodingKeys: String, CodingKey {
        case host
        case system
    }
    
    init(from decoder: Decoder) throws {
        
        print("📚 Node Info Decode START")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.host = try container.decode(Host.self, forKey: .host)
        self.system = try container.decode(RadixSystem.self, forKey: .system)
        print("📚 Node Info Decode DONE, initialized ✅")
    }
}

// MARK: - RadixModelTypeStaticSpecifying
public extension NodeInfo {
    static let serializer: RadixModelType = .nodeInfo
}
