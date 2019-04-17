//
//  NodeFinder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

public final class NodeFinder: NodeDiscovery {
    public typealias UseSSL = Bool
    public typealias URLFormatting = (Host) throws -> FormattedURL
    
    private let websocketsUrlFormatter: URLFormatting
    private let httpUrlFormatter: URLFormatting
    
    private let restClient: RESTClient
    
    public init(
        restClient: RESTClient,
        websocketsUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .websockets) },
        httpUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .hypertext) }
        ) {
        
        self.websocketsUrlFormatter = websocketsUrlFormatter
        self.httpUrlFormatter = httpUrlFormatter
        self.restClient = restClient
    }
    
    deinit {
        log.error("💣")
    }
}

// MARK: - NodeDiscovery
public extension NodeFinder {
    func loadNodes() -> Observable<[Node]> {
        return restClient.findNode()
            .flatMapLatest { (nodeIp: FormattedURL) -> Observable<[Node]> in
                RESTClientsRetainer.restClient(urlToNode: nodeIp).getLivePeers().asObservable()
                    .ifEmpty(throw: Error.noConnectionsForBootstrapNode(url: nodeIp.url))
                    .map { [unowned self] in try $0.map {
                        try Node(
                            info: $0,
                            websocketsUrl: try self.websocketsUrlFormatter($0.host),
                            httpUrl: try self.httpUrlFormatter($0.host)
                        )
                    }
                }
        }.debug()
    }
}

public extension NodeFinder {
    static var sunstone: NodeFinder {
        // swiftlint:disable:next force_try
        return try! NodeFinder(bootstrapHost: "https://sunstone.radixdlt.com")
    }
}

public extension NodeFinder {
    enum Error: Swift.Error {
        case noConnectionsForBootstrapNode(url: URL)
    }
}

// MARK: - Convenience Init
public extension NodeFinder {
    
    convenience init(
        bootstrapNode: FormattedURL,
        websocketsUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .websockets) },
        httpUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .hypertext) }
        ) {
        
        let restClient = DefaultRESTClient(url: bootstrapNode)
        
        self.init(
            restClient: restClient,
            websocketsUrlFormatter: websocketsUrlFormatter,
            httpUrlFormatter: httpUrlFormatter
        )
    }
    
    convenience init(
        bootstrapHost: Host,
        websocketsUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .websockets) },
        httpUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .hypertext) }
        ) throws {
        
        let bootstrapNodeURL = try URLFormatter.format(url: bootstrapHost, protocol: .hypertext, appendPath: false, useSSL: true)
        
        self.init(bootstrapNode: bootstrapNodeURL, websocketsUrlFormatter: websocketsUrlFormatter, httpUrlFormatter: httpUrlFormatter)
    }
}
