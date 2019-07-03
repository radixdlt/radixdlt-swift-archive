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
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    deinit {
        log.error("💣")
    }
}

public extension DefaultRESTClient {
    
    convenience init(url: URL) {
        self.init(httpClient: DefaultHTTPClient(baseURL: url))
    }
    
    convenience init(formattedUrl: FormattedURL) {
        self.init(url: formattedUrl.url)
    }
    
//    convenience init(node: Node) {
//        fatalError("dont use node when creating RESTClient...")
////        self.init(formattedUrl: node.httpUrl)
//    }
}
