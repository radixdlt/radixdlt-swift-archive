//
//  NodeDiscoveryHardCoded.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct NodeDiscoveryHardCoded: NodeDiscovery {
    private let urls: [FormattedURL]
    
    public init(urls: [FormattedURL]) {
        self.urls = urls
    }
}

// MARK: - NodeDiscovery
public extension NodeDiscoveryHardCoded {
    
    func loadNodes() -> Observable<[Node]> {
        return Observable<[FormattedURL]>.just(urls)
            .flatMap { (nodeUrls: [FormattedURL]) -> Observable<[Node]> in
                let nodeObservables: [Observable<Node>] = nodeUrls.map { (nodeUrl: FormattedURL) -> Observable<Node> in
                    RESTClientsRetainer.restClient(urlToNode: nodeUrl)
                        .networkDetails()
                        .map { $0.tcp }
                        .asObservable()
                        .first(ifEmptyThrow: Error.tcpNetworkDetailsEmptyForNode(url: nodeUrl.url))
                        .map {
                            return try Node(
                                info: $0,
                                websocketsUrl: try URLFormatter.format(url: nodeUrl, protocol: .websockets(appendPath: true), useSSL: !nodeUrl.isLocal),
                                httpUrl: try URLFormatter.format(url: nodeUrl, protocol: .hypertext(appendPath: true), useSSL: !nodeUrl.isLocal)
                            )
                    }
                }
                // [Observable<Node>] -> Observable<[Node]>
                return Observable.combineLatest(nodeObservables) { $0 }
        }
    }
}

public extension NodeDiscoveryHardCoded {
    enum Error: Swift.Error {
        case tcpNetworkDetailsEmptyForNode(url: URL)
    }
}
