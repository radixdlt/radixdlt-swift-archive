//
//  DefaultRESTClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultRESTClient: RESTClient {

    // Internal for testing only
    internal let httpClient: HTTPClient
    
    public init(url: FormattedURL) {
        self.httpClient = DefaultHTTPClient(baseURL: url)
    }
    
    deinit {
        log.error("💣")
    }
}

public extension DefaultRESTClient {
    convenience init(node: Node) {
        self.init(url: node.httpUrl)
    }
}

// MARK: - RESTClient
public extension DefaultRESTClient {
    
    func networkDetails() -> Observable<NodeNetworkDetails> {
        return httpClient.request(.network)
    }
    
    func getLivePeers() -> SingleWanted<[NodeInfo]> {
        return httpClient.request(.getLivePeers)
    }
}
