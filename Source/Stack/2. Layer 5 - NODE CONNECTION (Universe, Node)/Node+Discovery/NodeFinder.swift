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
        bootstrapNodeUrl: FormattedURL,
        websocketsUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(host: $0, protocol: .hypertext(appendPath: true)) },
        httpUrlFormatter: @escaping URLFormatting = { try URLFormatter.format(host: $0, protocol: .hypertext(appendPath: true)) }
        ) {
        self.bootstrapNodeUrl = bootstrapNodeUrl
        self.websocketsUrlFormatter = websocketsUrlFormatter
        self.httpUrlFormatter = httpUrlFormatter
        self.httpClient = DefaultHTTPClient(baseURL: bootstrapNodeUrl)
    }
    
    deinit {
        log.error("💣")
    }
}

public extension NodeFinder {
    func loadNodes() -> Observable<[Node]> {
        return httpClient.findNode()
            .map { try URLFormatter.format(ipAddress: $0, port: 443, protocol: .hypertext(appendPath: true), useSSL: true) }.asObservable()
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
        return NodeFinder(bootstrapNodeUrl: "https://sunstone.radixdlt.com")
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
