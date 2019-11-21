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
    RadixNetworkWebSocketsEpic
    where
    Request: JsonRpcMethodNodeAction,
    RpcMethodResult: JsonRpcResultAction
{
    
    // swiftlint:enable colon opening_brace
    
    public typealias MethodCall = (RPCClient, Request) -> Single<RpcMethodResult, Never>
    
    private let webSocketConnector: WebSocketConnector
    private let rpcClientFromWebSocket: RPCClientFromWebSocket
    private let methodCall: MethodCall
    
    private init(
        webSocketConnector: WebSocketConnector,
        rpcClientFromWebSocket: RPCClientFromWebSocket = .default,
        methodCall: @escaping MethodCall
    ) {
        self.webSocketConnector = webSocketConnector
        self.rpcClientFromWebSocket = rpcClientFromWebSocket
        self.methodCall = methodCall
    }
}

public extension RadixJsonRpcMethodEpic {
    
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState _: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        return nodeActionPublisher
            .compactMap(typeAs: Request.self)
            .flatMap { [weak self] rpcMethod -> AnyPublisher<RpcMethodResult, Never> in
                guard let selfNonWeak = self else {
                    return Empty<RpcMethodResult, Never>.init(completeImmediately: true).eraseToAnyPublisher()
                }
                return selfNonWeak.webSocketConnector.newClosedWebSocketConnectionToNode(rpcMethod.node)
                    .connectAndNotifyWhenConnected()
                    .map { selfNonWeak.rpcClientFromWebSocket.rpcClientForWebSocket($0) } // DefaultRPCClient(channel: $0) }
                    .flatMap { rpcClient in
                        return selfNonWeak.methodCall(rpcClient, rpcMethod)
                }.eraseToAnyPublisher()
        }
        .map { $0 as NodeAction }^
    }
}

// MARK: Instances
public extension RadixJsonRpcMethodEpic {
    
    static func createGetLivePeersEpic(webSockets webSocketsManager: WebSocketsManager) -> RadixNetworkWebSocketsEpic {
        createGetLivePeersEpic(webSocketConnector: .byWebSockets(manager: webSocketsManager))
    }
    
    static func createGetLivePeersEpic(webSocketConnector: WebSocketConnector) -> RadixNetworkWebSocketsEpic {
        
        RadixJsonRpcMethodEpic<GetLivePeersActionRequest, GetLivePeersActionResult>(
            webSocketConnector: webSocketConnector
        ) { rpcClient, action in
            rpcClient.getLivePeers()
                .map { GetLivePeersActionResult(node: action.node, result: $0) }
                .eraseToAnyPublisher()
        }
    }
    
    static func createGetNodeInfoEpic(webSockets webSocketsManager: WebSocketsManager) -> RadixNetworkWebSocketsEpic {
        createGetNodeInfoEpic(webSocketConnector: .byWebSockets(manager: webSocketsManager))
    }
    
    static func createGetNodeInfoEpic(webSocketConnector: WebSocketConnector) -> RadixNetworkWebSocketsEpic {
        RadixJsonRpcMethodEpic<GetNodeInfoActionRequest, GetNodeInfoActionResult>(
            webSocketConnector: webSocketConnector
        ) { rpcClient, action in
            rpcClient.getInfo()
                .map { GetNodeInfoActionResult(node: action.node, result: $0) }
                .eraseToAnyPublisher()
        }
    }
    
    static func createUniverseConfigEpic(webSockets webSocketsManager: WebSocketsManager) -> RadixNetworkWebSocketsEpic {
        createUniverseConfigEpic(webSocketConnector: .byWebSockets(manager: webSocketsManager))
    }
    
    static func createUniverseConfigEpic(webSocketConnector: WebSocketConnector) -> RadixNetworkWebSocketsEpic {
        
        RadixJsonRpcMethodEpic<GetUniverseConfigActionRequest, GetUniverseConfigActionResult>(
            webSocketConnector: webSocketConnector
        ) { rpcClient, action in
            rpcClient.getUniverseConfig()
                .map { GetUniverseConfigActionResult(node: action.node, result: $0) }
                .eraseToAnyPublisher()
        }
        
    }
}
