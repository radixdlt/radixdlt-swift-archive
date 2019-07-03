////
////  NodeFinder.swift
////  RadixSDK iOS
////
////  Created by Alexander Cyon on 2019-03-25.
////  Copyright © 2019 Radix DLT. All rights reserved.
////
//
//import Foundation
//import RxSwift
//import Alamofire
//
//// MARK: - NodeFinder
//public final class NodeFinder: NodeDiscovery, SuitableNodeDiscovering {
//    public typealias Error = NodeDiscoveryError
//    
//    private let urlToSomeOriginNodeUsedToFinderOtherNodes: Observable<FormattedURL>
////    private let selectNodeToConnectTo: (NodeSelection, NonEmptySet<Node>) -> (Node) = {
////        switch $0 {
////        case .random: return $1.randomElement()
////        }
////    }
//    
//    private init(
//        urlToSomeOriginNodeUsedToFinderOtherNodes: Observable<FormattedURL>
//    ) {
//        self.urlToSomeOriginNodeUsedToFinderOtherNodes = urlToSomeOriginNodeUsedToFinderOtherNodes
////
////        self.websocketsUrlFormatter = websocketsUrlFormatter ?? { try URLFormatter.format(host: $0, protocol: .websockets) }
////        self.httpUrlFormatter = httpUrlFormatter ?? { try URLFormatter.format(host: $0, protocol: .hypertext) }
////
////        self.makeLivePeersRequester = makeLivePeersRequester ?? { RESTClientsRetainer.restClient(urlToNode: $0) }
////        self.makeUniverseConfigRequester = makeUniverseConfigRequester ?? { RESTClientsRetainer.restClient(urlToNode: $0) }
//    }
//    
//    deinit {
//        log.error("💣")
//    }
//}
//
//public extension NodeFinder {
//    convenience init(
//        originNodeFinder: OriginNodeFinder
////        makeLivePeersRequester: MakeLivePeersRequester? = nil,
////        websocketsUrlFormatter: URLFormatting? = nil,
////        httpUrlFormatter: URLFormatting? = nil
//    ) {
//      
//        self.init(
//            urlToSomeOriginNodeUsedToFinderOtherNodes: originNodeFinder.findSomeOriginNode().asObservable()
////            makeLivePeersRequester: makeLivePeersRequester,
////            websocketsUrlFormatter: websocketsUrlFormatter,
////            httpUrlFormatter: httpUrlFormatter
//        )
//    }
//    
//    convenience init(
//        urlToSomeOriginNode: FormattedURL
////        makeLivePeersRequester: MakeLivePeersRequester? = nil,
////        websocketsUrlFormatter: URLFormatting? = nil,
////        httpUrlFormatter: URLFormatting? = nil
//        ) {
//        
//        self.init(
//            urlToSomeOriginNodeUsedToFinderOtherNodes: Observable.just(urlToSomeOriginNode)
////            makeLivePeersRequester: makeLivePeersRequester,
////            websocketsUrlFormatter: websocketsUrlFormatter,
////            httpUrlFormatter: httpUrlFormatter
//        )
//    }
//}
//
//// MARK: - NodeDiscovery
//public extension NodeFinder {
//    func loadNodes() -> Observable<[Node]> {
//        func mapToNode(infos: [NodeInfo]) throws -> [Node] {
//            return try infos.map { try Node(nodeInfo: $0) }
//        }
//        
//        return livePeersRequester.flatMap {
//            $0.getLivePeers().asObservable()
//                .ifEmpty(throw: NodeDiscoveryError.foundZeroNodes)
//                .map(mapToNode)
//        }
//    }
//    
//    var configOfNode: (Node) -> Single<UniverseConfig> {
//        implementMe()
////        return { (node: Node) -> Observable<UniverseConfig> in
////            return self.makeUniverseConfigRequester(node.httpUrl).getUniverseConfig()
////        }
//    }
//}
//
//private extension NodeFinder {
//    var livePeersRequester: Observable<LivePeersRequesting> {
////        return urlToSomeOriginNodeUsedToFinderOtherNodes.map { [unowned self] in
////            self.makeLivePeersRequester($0)
////        }
//        implementMe()
//    }
//}
//
