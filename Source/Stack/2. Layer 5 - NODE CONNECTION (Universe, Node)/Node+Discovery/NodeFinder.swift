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
    
    private let bootstrapNodeUrl: FormattedURL
    private let websocketsUrlFormatter: URLFormatting
    private let httpUrlFormatter: URLFormatting
    
    private let httpClient: DefaultHTTPClient
    
    public init(
        bootstrapNode: FormattedURL,
        websocketsUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .websockets) },
        httpUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .hypertext) }
        ) {
        self.bootstrapNodeUrl = bootstrapNode
        self.websocketsUrlFormatter = websocketsUrlFormatter
        self.httpUrlFormatter = httpUrlFormatter
        self.httpClient = DefaultHTTPClient(baseURL: bootstrapNodeUrl)
    }
    
    public convenience init(
        bootstrapHost: Host,
        websocketsUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .websockets) },
        httpUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(url: $0, protocol: .hypertext) }
        ) throws {
        let bootstrapNodeURL = try URLFormatter.format(url: bootstrapHost, protocol: .hypertext, appendPath: false, useSSL: true)
        self.init(bootstrapNode: bootstrapNodeURL, websocketsUrlFormatter: websocketsUrlFormatter, httpUrlFormatter: httpUrlFormatter)
    }
    
    deinit {
        log.error("💣")
    }
}

public extension NodeFinder {
    func loadNodes() -> Observable<[Node]> {
        return httpClient.findNode()
            .map { try Host(ipAddress: $0, port: 443) }
            .map { try URLFormatter.format(url: $0, protocol: .hypertext, useSSL: true) }.asObservable()
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

public extension ObservableType where E: LengthMeasurable {
    func ifEmpty<ErrorType>(throw errorIfEmpty: ErrorType) -> Observable<E> where ErrorType: Swift.Error {
        return asObservable().map { lengthMeasurable in
            guard let nonEmpty = lengthMeasurable.nilIfEmpty() else {
                throw errorIfEmpty
            }
            return nonEmpty
        }
    }
}

public extension ObservableType where E: Sequence {
    func first<ErrorType>(ifEmptyThrow errorIfEmpty: ErrorType) -> Observable<E.Element> where ErrorType: Swift.Error {
        return asObservable().map { sequence in
            let array = [E.Element](sequence)
            guard let nonEmpty = array.nilIfEmpty() else {
                throw errorIfEmpty
            }
            return nonEmpty[0]
        }
    }
}
