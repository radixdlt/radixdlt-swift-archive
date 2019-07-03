//
//  Node.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

// swiftlint:disable colon opening_brace

/// Unique network node endpoint.
public struct Node:
    Hashable,
    Equatable
{
    // swiftlint:enable colon opening_brace
    
    public let websocketsUrl: FormattedURL
//    public let httpUrl: FormattedURL
//    private let nodeInfo: NodeInfo
    
    public init(
//        info: NodeInfo,
        websocketsUrl: FormattedURL
//        httpUrl: FormattedURL
    ) {
//        self.nodeInfo = info
        self.websocketsUrl = websocketsUrl
//        self.httpUrl = httpUrl
    }
}

public extension Node {

    init(nodeInfo: NodeInfo) throws {
        
        let websocketsUrl = try URLFormatter.format(host: nodeInfo.host, protocol: .websockets)
//        let httpUrl = try URLFormatter.format(host: nodeInfo.host, protocol: .hypertext)
        
        self.init(
//            info: nodeInfo,
            websocketsUrl: websocketsUrl
//            httpUrl: httpUrl
        )
    }
    
    init(host: Host, isUsingSSL: Bool) throws {
        let websocketsUrl = try URLFormatter.format(host: host, protocol: .websockets, useSSL: isUsingSSL)
        self.init(websocketsUrl: websocketsUrl)
    }
    
    init(domain: String, port: Port, isUsingSSL: Bool) throws {
        let host = try Host(domain: domain, port: port)
        try self.init(host: host, isUsingSSL: isUsingSSL)
    }
}

//// MARK: Shard
//public extension Node {
//    func canServe(shard: Shard) -> Bool {
//        return nodeInfo.system.shardSpace.contains(shard: shard)
//    }
//}

//public extension Node {
//    var request: URLRequest {
//        return URLRequest(url: httpUrl.url)
//    }
//}
