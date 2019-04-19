//
//  RESTClient+DefaultImplementations.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public extension NodeAddressRequesting where Self: HTTPClientOwner {
    func findNode() -> SingleWanted<FormattedURL> {
        return httpClient.loadContent(of: "/node-finder")
            .map { try Host(ipAddress: $0, port: 443) }
            .map { try URLFormatter.format(url: $0, protocol: .hypertext, useSSL: true) }
    }
}

public extension NodeNetworkDetailsRequesting where Self: HTTPClientOwner {
    func networkDetails() -> Observable<NodeNetworkDetails> {
        return httpClient.request(.network)
    }
}

public extension LivePeersRequesting where Self: HTTPClientOwner {
    func getLivePeers() -> SingleWanted<[NodeInfo]> {
        return httpClient.request(.getLivePeers)
    }
}

