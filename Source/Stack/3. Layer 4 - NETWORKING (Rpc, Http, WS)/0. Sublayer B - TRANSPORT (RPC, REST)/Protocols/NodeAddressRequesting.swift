//
//  OriginNodeFinding.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol OriginNodeFinding {
    func findSomeOriginNode(port: Port) -> Single<Node>
}

public extension OriginNodeFinding where Self: HTTPClientOwner {
    func findSomeOriginNode(port: Port = .nodeFinder) -> Single<Node> {
        return httpClient.loadContent(of: "/node-finder")
            .map { try Host(domain: $0, port: port) }
            .map { try Node.init(host: $0, isUsingSSL: true) }
    }
}

public final class OriginNodeFinder: OriginNodeFinding, HTTPClientOwner {
//    private let urlToFinderOfSomeOriginNode: URL
    
    public let httpClient: HTTPClient
    
    private init(formattedUrlToFinderOfSomeOriginNode: FormattedURL) {
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
        do {
            return try OriginNodeFinder(domain: "https://betanet.radixdlt.com")
        } catch { incorrectImplementation("Should always be able to create an OriginNodeFinder for betanet") }
    }
}
