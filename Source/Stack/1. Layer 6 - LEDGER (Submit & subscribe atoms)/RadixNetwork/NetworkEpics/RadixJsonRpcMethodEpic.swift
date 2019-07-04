//
//  RadixJsonRpcMethodEpic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class RadixJsonRpcMethodEpic<Request, Result>: NetworkWebsocketEpic where Request: JsonRpcMethodNodeAction, Result: JsonRpcResultAction {
    
    public typealias MethodCall = BiFunction<RPCClient, Request, Single<Result>>
    
    public let webSockets: WebSocketsEpic.WebSockets
    private let methodCall: MethodCall
    
    private init(
        webSockets: WebSocketsEpic.WebSockets,
        methodCall: @escaping (RPCClient, Request) -> Single<Result>
    ) {
        self.webSockets = webSockets
        self.methodCall = BiFunction(methodCall)
    }
}

public extension RadixJsonRpcMethodEpic {
    func epic(actions: Observable<NodeAction>, networkState: Observable<RadixNetworkState>) -> Observable<NodeAction> {
        return actions
            .ofType(Request.self)
            .do(onNext: { log.debug("Request: \($0)") })
            .flatMapSingle { [unowned self] (rpcMethod: Request) -> Single<Result> in
                log.debug("Waiting for ws connection to node")
                return self.waitForConnectionReturnWS(toNode: rpcMethod.node).debug()
                    .map { DefaultRPCClient(channel: $0) }
                    .flatMap { rpcClient -> Single<Result> in
                        return self.methodCall.apply(rpcClient, rpcMethod)
                    }
            }.map { $0 }.debug()
    }
}

// MARK: Instances
public extension RadixJsonRpcMethodEpic {
    static func createGetLivePeersEpic(webSockets: WebSocketsEpic.WebSockets) -> NetworkWebsocketEpic {
        return RadixJsonRpcMethodEpic<GetLivePeersActionRequest, GetLivePeersActionResult>(
            webSockets: webSockets
        ) { (rpcClient: RPCClient, action: GetLivePeersActionRequest) -> Single<GetLivePeersActionResult> in
            rpcClient.getLivePeers().map { GetLivePeersActionResult(node: action.node, result: $0) }
        }
    }
    
    static func createGetNodeInfoEpic(webSockets: WebSocketsEpic.WebSockets) -> NetworkWebsocketEpic {
        return RadixJsonRpcMethodEpic<GetNodeInfoActionRequest, GetNodeInfoActionResult>(
            webSockets: webSockets
        ) { (rpcClient: RPCClient, action: GetNodeInfoActionRequest) -> Single<GetNodeInfoActionResult> in
            rpcClient.getInfo().map { GetNodeInfoActionResult(node: action.node, result: $0) }
        }
    }
    
    static func createUniverseConfigEpic(webSockets: WebSocketsEpic.WebSockets) -> NetworkWebsocketEpic {
        return RadixJsonRpcMethodEpic<GetUniverseConfigActionRequest, GetUniverseConfigActionResult>(
            webSockets: webSockets
        ) { (rpcClient: RPCClient, action: GetUniverseConfigActionRequest) -> Single<GetUniverseConfigActionResult> in
            rpcClient.getUniverseConfig().map { GetUniverseConfigActionResult(node: action.node, result: $0) }
        }
    }
}
