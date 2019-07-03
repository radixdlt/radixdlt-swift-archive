//
//  RESTClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

// swiftlint:disable colon opening_brace

public protocol RESTClient:
    NodeNetworkDetailsRequesting,
    NodeInfoRequesting,
    LivePeersRequesting,
    UniverseConfigRequesting
{
    // swiftlint:enable colon opening_brace
}

public extension NodeNetworkDetailsRequesting where Self: RESTClient {
    
    func getInfo() -> Single<NodeInfo> {
        return networkDetails().map {
            $0.udp
        }.flatMap { (nodesInfos: [NodeInfo]) -> Single<NodeInfo> in
            return Observable.from(nodesInfos).asSingle()
        }
    }
}
