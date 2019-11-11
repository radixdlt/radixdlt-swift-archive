//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import Combine

// swiftlint:disable colon opening_brace

/// A multipurpose RadixNetworkEpic wrapping JSON-RPC API calls
public final class RadixJsonRpcMethodEpic<Request, RpcMethodResult>:
    NetworkWebsocketEpic
where
    Request: JsonRpcMethodNodeAction,
    RpcMethodResult: JsonRpcResultAction
{
    
    // swiftlint:enable colon opening_brace

    public typealias MethodCall = (RPCClient, Request) -> Single<RpcMethodResult, Never>
    
    public let webSockets: WebSocketsManager
    private let methodCall: MethodCall
    
    private init(
        webSockets: WebSocketsManager,
        methodCall: @escaping MethodCall
    ) {
        self.webSockets = webSockets
        self.methodCall = methodCall
    }
}

public extension RadixJsonRpcMethodEpic {
    
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        return nodeActionPublisher
            .compactMap(typeAs: Request.self)
            .flatMap { [unowned self] rpcMethod in
                return self.openWebSocketAndAwaitConnection(toNode: rpcMethod.node)
                    .map { DefaultRPCClient(channel: $0) }
                    .flatMap { rpcClient in
                        return self.methodCall(rpcClient, rpcMethod)
                    }
            }
        .map { $0 as NodeAction }^
    }
}

// MARK: Instances
public extension RadixJsonRpcMethodEpic {
    
    static func createGetLivePeersEpic(webSockets: WebSocketsManager) -> NetworkWebsocketEpic {
        
        return RadixJsonRpcMethodEpic<GetLivePeersActionRequest, GetLivePeersActionResult>(
            webSockets: webSockets
        ) { rpcClient, action in
            rpcClient.getLivePeers(
            ).map { GetLivePeersActionResult(node: action.node, result: $0) }
                .eraseToAnyPublisher()
        }
    }
    
    static func createGetNodeInfoEpic(webSockets: WebSocketsManager) -> NetworkWebsocketEpic {
        RadixJsonRpcMethodEpic<GetNodeInfoActionRequest, GetNodeInfoActionResult>(
            webSockets: webSockets
        ) { rpcClient, action in
            rpcClient.getInfo()
                .map { GetNodeInfoActionResult(node: action.node, result: $0) }
                .eraseToAnyPublisher()
        }
    }
    
    static func createUniverseConfigEpic(webSockets: WebSocketsManager) -> NetworkWebsocketEpic {
        
        return RadixJsonRpcMethodEpic<GetUniverseConfigActionRequest, GetUniverseConfigActionResult>(
            webSockets: webSockets
        ) { rpcClient, action in
            rpcClient.getUniverseConfig()
                .map { GetUniverseConfigActionResult(node: action.node, result: $0) }
                .eraseToAnyPublisher()
        }

    }
}
