//
//  DefaultRESTClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultRESTClient: RESTClient, HTTPClientOwner {

    public let httpClient: HTTPClient
    
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
