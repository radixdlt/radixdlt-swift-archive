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
    public typealias MakeFindNodeRequester = (FormattedURL) -> NodeAddressRequesting
    public typealias MakeLivePeersRequester = (FormattedURL) -> LivePeersRequesting
    private let makeFindNodeRequester: MakeFindNodeRequester
    private let makeLivePeersRequester: MakeLivePeersRequester
    private let websocketsUrlFormatter: URLFormatting
    private let httpUrlFormatter: URLFormatting
    
    private let nodeFindingURL: FormattedURL
    
    public init(
        nodeFindingURL: FormattedURL,
        makeFindNodeRequester: MakeFindNodeRequester? = nil,
        makeLivePeersRequester: MakeLivePeersRequester? = nil,
        websocketsUrlFormatter: URLFormatting? = nil,
        httpUrlFormatter: URLFormatting? = nil
    ) {
        self.nodeFindingURL = nodeFindingURL

        self.websocketsUrlFormatter = websocketsUrlFormatter ?? { try URLFormatter.format(url: $0, protocol: .websockets) }

        self.httpUrlFormatter = httpUrlFormatter ?? { try URLFormatter.format(url: $0, protocol: .hypertext) }

        self.makeFindNodeRequester = makeFindNodeRequester ?? { RESTClientsRetainer.restClient(urlToNode: $0) }
        
        self.makeLivePeersRequester = makeLivePeersRequester ?? { RESTClientsRetainer.restClient(urlToNode: $0) }
    }
    
    deinit {
        log.error("💣")
    }
}

// MARK: - NodeDiscovery
public extension NodeFinder {
    func loadNodes() -> Observable<[Node]> {
        func mapToNode(infos: [NodeInfo]) throws -> [Node] {
            return try infos.map {
                try Node(
                    info: $0,
                    websocketsUrl: try websocketsUrlFormatter($0.host),
                    httpUrl: try httpUrlFormatter($0.host)
                )
            }
        }
        return makeFindNodeRequester(nodeFindingURL)
            .findNode()
            .flatMapLatest { [unowned self] (nodeIp: FormattedURL) -> Observable<[Node]> in
                self.makeLivePeersRequester(nodeIp)
                    .getLivePeers()
                    .asObservable()
                    .ifEmpty(throw: Error.noConnectionsForBootstrapNode(url: nodeIp.url))
                    .map(mapToNode)
        }
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
        bootstrapHost: Host,
        makeFindNodeRequester: MakeFindNodeRequester? = nil,
        makeLivePeersRequester: MakeLivePeersRequester? = nil,
        websocketsUrlFormatter: URLFormatting? = nil,
        httpUrlFormatter: URLFormatting? = nil
    ) throws {
    
        let nodeFindingURL = try URLFormatter.format(url: bootstrapHost, protocol: .hypertext, appendPath: false, useSSL: true)
        
        self.init(
            nodeFindingURL: nodeFindingURL,
            makeFindNodeRequester: makeFindNodeRequester,
            makeLivePeersRequester: makeLivePeersRequester,
            websocketsUrlFormatter: websocketsUrlFormatter,
            httpUrlFormatter: httpUrlFormatter
        )
    }
}
