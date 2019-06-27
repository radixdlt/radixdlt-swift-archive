//
//  NodeAddressRequesting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol NodeAddressRequesting {
    func findSomeOriginNode() -> SingleWanted<FormattedURL>
}

public extension NodeAddressRequesting where Self: HTTPClientOwner {
    func findSomeOriginNode() -> SingleWanted<FormattedURL> {
        return httpClient.loadContent(of: "/node-finder")
            .map { try Host(domain: $0, port: .nodeFinder) }
            .map { try URLFormatter.format(host: $0, protocol: .hypertext, useSSL: true) }
    }
}

public final class OriginNodeFinder: NodeAddressRequesting, HTTPClientOwner {
//    private let urlToFinderOfSomeOriginNode: URL
    
    public let httpClient: HTTPClient
    
    public init(formattedUrlToFinderOfSomeOriginNode: FormattedURL) {
        self.httpClient = DefaultHTTPClient(formattedUrl: formattedUrlToFinderOfSomeOriginNode)
    }
}

public extension OriginNodeFinder {
    convenience init(finderOfSomeOriginNode: Host) throws {
        
        let formattedUrlToFinderOfSomeOriginNode = try URLFormatter.format(
            host: finderOfSomeOriginNode,
            protocol: .hypertext,
            appendPath: false,
            useSSL: true
        )
        
        self.init(formattedUrlToFinderOfSomeOriginNode: formattedUrlToFinderOfSomeOriginNode)
    }
    
    convenience init(domain: String, port: Port = .nodeFinder) throws {
        let host = try Host(domain: domain, port: port)
        try self.init(finderOfSomeOriginNode: host)
    }
}

public extension OriginNodeFinder {
    static var betanet: OriginNodeFinder {
        // swiftlint:disable:next force_try
        return try! OriginNodeFinder(domain: "https://betanet.radixdlt.com")
    }
}
