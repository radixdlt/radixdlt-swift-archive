//
//  ConnectWebSocketEpic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
                self.webSockets.webSocket(to: $0.node, shouldConnect: true)
                
            }).ignoreElementsObservable()
        
        let onClose: Observable<NodeAction> = actions
            .filter { type(of: $0) == CloseWebSocketAction.self }
            .do(onNext: { [unowned self] in
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
