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
import RxSwift

public final class ConnectWebSocketEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsEpic.WebSockets
    
    private let disposeBag = DisposeBag()
    
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}

public extension ConnectWebSocketEpic {
    func epic(actions: Observable<NodeAction>, networkState: Observable<RadixNetworkState>) -> Observable<NodeAction> {
        let onConnect: Observable<NodeAction> = actions
            .filter { type(of: $0) == ConnectWebSocketAction.self }
            .do(onNext: { [unowned self] in
                log.verbose("Acting upon ConnectWebSocketAction")
                self.webSockets.webSocket(to: $0.node, shouldConnect: true)
                
            }).ignoreElementsObservable()
        
        let onClose: Observable<NodeAction> = actions
            .filter { type(of: $0) == CloseWebSocketAction.self }
            .do(onNext: { [unowned self] in
                log.verbose("Acting upon CloseWebSocketAction")
                self.webSockets.ifNoOneListensCloseAndRemoveWebsocket(toNode: $0.node)
            }).ignoreElementsObservable()
        
        return Observable.merge(onConnect, onClose)
    }
}

extension ObservableConvertibleType {
    func ignoreElementsObservable() -> Observable<Element> {
        return self.asObservable().materialize().flatMap { event in
            return Observable<Element>.create { observer in
                switch event {
                case .error(let error):
                    observer.onError(error)
                case .completed: observer.onCompleted()
                case .next: break /* the purpose of this switch is to NOT pass along any `next` event */
                }
                return Disposables.create()
            }
        }
    }
}

public final class RadixJsonRpcAutoConnectEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsEpic.WebSockets
    
    private let disposeBag = DisposeBag()
    
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}

public extension RadixJsonRpcAutoConnectEpic {
    func epic(actions: Observable<NodeAction>, networkState: Observable<RadixNetworkState>) -> Observable<NodeAction> {
        return actions
            .filter { $0 is JsonRpcMethodNodeAction }
            .flatMap { [unowned self] rpcMethodAction -> Observable<NodeAction> in
                return self.waitForConnection(toNode: rpcMethodAction.node)
                    .andThen(
                        Observable.just(rpcMethodAction)
                            .ignoreElementsObservable()
                )
        }
        
    }
}

public final class RadixJsonRpcAutoCloseEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsEpic.WebSockets
    
    private let disposeBag = DisposeBag()
    
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}
public extension RadixJsonRpcAutoCloseEpic {
    func epic(actions: Observable<NodeAction>, networkState: Observable<RadixNetworkState>) -> Observable<NodeAction> {
        return actions
            .filter { $0 is BaseJsonRpcResultAction }
            .delay(RxTimeInterval.seconds(5), scheduler: MainScheduler.instance)
            .do(onNext: { [unowned self] actionResult in
                self.webSockets.ifNoOneListensCloseAndRemoveWebsocket(toNode: actionResult.node)
            }).ignoreElementsObservable()
        
    }
}
