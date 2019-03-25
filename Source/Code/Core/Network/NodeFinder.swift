//
//  NodeFinder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class NodeFinder {
    private let restClient: RESTClient
    private let port: Int?
    public init(restClient: RESTClient, port: Int? = nil) {
        self.restClient = restClient
        self.port = port
    }
}

public extension NodeFinder {
    convenience init(baseURL: URL? = nil, port: Int? = nil) {
        self.init(restClient: DefaultRESTClient(baseURL: baseURL), port: port)
    }
    
    convenience init(enviroment: Enviroment, port: Int? = nil) {
        self.init(baseURL: enviroment.baseURL, port: port)
    }
}

public extension NodeFinder {
    func getSeed() -> Observable<Node> {
        let port = self.port
        return restClient.request(
                router: NodeRouter.livePeers,
                decodeAs: [FoundNode].self
            ).asObservable()
            .concatMap {
                Observable.from($0.map { Node(found: $0, port: port) })
        }
    }
}
