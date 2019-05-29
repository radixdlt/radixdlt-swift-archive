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
    public let httpUrl: FormattedURL
    private let nodeInfo: NodeInfo
    
    public init(info: NodeInfo, websocketsUrl: FormattedURL, httpUrl: FormattedURL) throws {
        self.nodeInfo = info
        self.websocketsUrl = websocketsUrl
        self.httpUrl = httpUrl
    }
}

// MARK: Shard
public extension Node {
    func canServe(shard: Shard) -> Bool {
        return nodeInfo.system.shards.range.contains(shard)
    }
}

public extension Node {
    var request: URLRequest {
        return URLRequest(url: httpUrl.url)
    }
}
