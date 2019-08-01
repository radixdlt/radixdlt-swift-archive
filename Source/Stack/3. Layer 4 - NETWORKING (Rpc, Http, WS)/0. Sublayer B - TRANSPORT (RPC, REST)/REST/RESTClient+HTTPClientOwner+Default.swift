//
//  RESTClient+DefaultImplementations.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public extension NodeNetworkDetailsRequesting where Self: HTTPClientOwner {
    func networkDetails() -> Single<NodeNetworkDetails> {
        return httpClient.request(.network)
    }
}

public extension LivePeersRequesting where Self: HTTPClientOwner {
    func getLivePeers() -> Single<[NodeInfo]> {
        return httpClient.request(.getLivePeers)
    }
}

public extension UniverseConfigRequesting where Self: HTTPClientOwner {
    func getUniverseConfig() -> Single<UniverseConfig> {
        return httpClient.request(.getUniverseConfig)
    }
}
