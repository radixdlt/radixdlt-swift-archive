//
//  NodeRunnerData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

public class NodeRunnerData:
    RadixModelTypeStaticSpecifying,
    Decodable,
    Equatable {
    // swiftlint:enable colon
    
    public struct Host: Decodable {
        public let ipAddress: String
        public let port: Int
        
        public enum CodingKeys: String, CodingKey {
            case ipAddress = "ip"
            case port
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.port = try container.decode(Int.self, forKey: .port)
            self.ipAddress = try container.decode(StringValue.self, forKey: .ipAddress).stringValue
        }
    }
    
    public let ipAddress: String
    public let system: RadixSystem
    public init(ipAddress: String, system: RadixSystem) {
        self.ipAddress = ipAddress
        self.system = system
    }
    
    public class var type: RadixModelType {
        return .nodeRunnerData
    }
    
    public enum CodingKeys: String, CodingKey {
        case host
        case system
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let host = try container.decode(Host.self, forKey: .host)
        self.ipAddress = host.ipAddress
        self.system = try container.decode(RadixSystem.self, forKey: .system)
    }
    
    public static func == (lhs: NodeRunnerData, rhs: NodeRunnerData) -> Bool {
        return lhs.ipAddress == rhs.ipAddress && lhs.system.shards == rhs.system.shards
    }

}

public extension NodeRunnerData {

    convenience init(ipAddress: String, shards: Shards) {
        self.init(
            ipAddress: ipAddress,
            system: RadixSystem(shards: shards)
        )
    }
    
    convenience init(ipAddress: String, lowerShard: Shard, upperShard: Shard) throws {
        self.init(ipAddress: ipAddress, shards: try Shards(lower: lowerShard, upper: upperShard))
    }
}

public final class UDPNodeRunnerData: NodeRunnerData {
    public override class var type: RadixModelType {
        return .udpNodeRunnerData
    }
}
