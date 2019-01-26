//
//  NodeRunnerData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public class NodeRunnerData: Codable {
    public let ipAddress: String
    public let system: RadixSystem
    public init(ipAddress: String, system: RadixSystem) {
        self.ipAddress = ipAddress
        self.system = system
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

public final class UDPNodeRunnerData: NodeRunnerData {}
