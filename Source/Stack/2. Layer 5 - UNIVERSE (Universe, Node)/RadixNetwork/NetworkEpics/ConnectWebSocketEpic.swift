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

public final class ConnectWebSocketEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsEpic.WebSockets
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}

public extension ConnectWebSocketEpic {
    func epic(actions: CombineObservable<NodeAction>, networkState: CombineObservable<RadixNetworkState>) -> CombineObservable<NodeAction> {
//        let onConnect: CombineObservable<NodeAction> = actions
//            .filter { type(of: $0) == ConnectWebSocketAction.self }
//            .do(onNext: { [unowned self] in
//                log.verbose("Acting upon ConnectWebSocketAction")
//                self.webSockets.webSocket(to: $0.node, shouldConnect: true)
//
//            }).ignoreElementsObservable()
//
//        let onClose: CombineObservable<NodeAction> = actions
//            .filter { type(of: $0) == CloseWebSocketAction.self }
//            .do(onNext: { [unowned self] in
//                log.verbose("Acting upon CloseWebSocketAction")
//                self.webSockets.ifNoOneListensCloseAndRemoveWebsocket(toNode: $0.node)
//            }).ignoreElementsObservable()
//
//        return CombineObservable.merge(onConnect, onClose)
        combineMigrationInProgress()
    }
}

public final class RadixJsonRpcAutoConnectEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsEpic.WebSockets
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}

public extension RadixJsonRpcAutoConnectEpic {
    func epic(actions: CombineObservable<NodeAction>, networkState: CombineObservable<RadixNetworkState>) -> CombineObservable<NodeAction> {
//        return actions
//            .filter { $0 is JsonRpcMethodNodeAction }
//            .flatMap { [unowned self] rpcMethodAction -> CombineObservable<NodeAction> in
//                return self.waitForConnection(toNode: rpcMethodAction.node)
//                    .andThen(
//                        CombineObservable.just(rpcMethodAction)
//                            .ignoreElementsObservable()
//                )
//        }
        combineMigrationInProgress()
        
    }
}

public final class RadixJsonRpcAutoCloseEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsEpic.WebSockets
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}
public extension RadixJsonRpcAutoCloseEpic {
    func epic(actions: CombineObservable<NodeAction>, networkState: CombineObservable<RadixNetworkState>) -> CombineObservable<NodeAction> {
//        return actions
//            .filter { $0 is BaseJsonRpcResultAction }
//            .delay(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
//            .do(onNext: { [unowned self] actionResult in
//                self.webSockets.ifNoOneListensCloseAndRemoveWebsocket(toNode: actionResult.node)
//            }).ignoreElementsObservable()
        combineMigrationInProgress()
        
    }
}
