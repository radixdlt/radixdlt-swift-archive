//
//  RESTClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public protocol RESTClient:
    NodeNetworkDetailsRequesting,
    NodeInfoRequesting,
    LivePeersRequesting,
    UniverseConfigRequesting
{
    // swiftlint:enable colon opening_brace
}

public extension NodeNetworkDetailsRequesting where Self: NodeInfoRequesting {
    
    func getInfo() -> SingleWanted<NodeInfo> {
        return networkDetails().map {
            $0.udp
        }.flatMap { (nodesInfos: [NodeInfo]) -> SingleWanted<NodeInfo> in
            return SingleWanted.from(nodesInfos)
        }
    }
}
