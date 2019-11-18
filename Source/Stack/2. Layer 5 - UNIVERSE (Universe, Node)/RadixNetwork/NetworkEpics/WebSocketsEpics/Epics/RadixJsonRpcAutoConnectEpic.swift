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

public final class RadixJsonRpcAutoConnectEpic: RadixNetworkWebSocketsEpic {
   
    private let webSocketConnector: WebSocketConnector
    
    public init(webSocketConnector: WebSocketConnector) {
        self.webSocketConnector = webSocketConnector
    }
}

public extension RadixJsonRpcAutoConnectEpic {
    convenience init(webSockets webSocketsManager: WebSocketsManager) {
        self.init(webSocketConnector: .byWebSockets(manager: webSocketsManager))
    }
}

public extension RadixJsonRpcAutoConnectEpic {
    
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState _: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {

        nodeActionPublisher
            .filter { $0 is JsonRpcMethodNodeAction }^
            .flatMap { [weak self] rpcMethodAction -> AnyPublisher<NodeAction, Never> in
                guard let self = self else {
                    return Empty<NodeAction, Never>.init(completeImmediately: true).eraseToAnyPublisher()
                }
                return self.webSocketConnector.newClosedWebSocketConnectionToNode(rpcMethodAction.node)
                    .connectAndNotifyWhenConnected()
                    .ignoreOutput(mapToType: NodeAction.self)
            }^
        
    }
}
