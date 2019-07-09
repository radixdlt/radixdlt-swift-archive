//
//  SubmitAtomEpic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

let delayFromCancelObservationOfAtomStatusToClosingWebsocket = DispatchTimeInterval.seconds(5)

public final class SubmitAtomEpic: NetworkWebsocketEpic {
    
    public let webSockets: WebSocketsEpic.WebSockets
    private let disposeBag = DisposeBag()
    
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}

public extension SubmitAtomEpic {
    func epic(actions: Observable<NodeAction>, networkState: Observable<RadixNetworkState>) -> Observable<NodeAction> {
        
        let foundNode: Observable<NodeAction> = actions
            .ofType(FindANodeResultAction.self)
            .filter { $0.request is SubmitAtomActionRequest }
            .map {
                let request = castOrKill(instance: $0.request, toType: SubmitAtomActionRequest.self)
                return SubmitAtomActionSend(request: request, node: $0.node)
        }
        
        let submitToNode: Observable<NodeAction> = actions
            .ofType(SubmitAtomActionSend.self)
            .flatMap { [unowned self] in
                self.waitForConnection(toNode: $0.node)
                    .andThen(self.submitAtom(sendAction: $0, toNode: $0.node))
        }
        
        return Observable.merge(
            foundNode,
            submitToNode
        )
    }
}

private extension SubmitAtomEpic {

    // swiftlint:disable:next function_body_length
    func submitAtom(sendAction: SubmitAtomActionSend, toNode node: Node) -> Observable<NodeAction> {
        let websocketToNode = webSockets.webSocket(to: node, shouldConnect: false)
        let rpcClient =  DefaultRPCClient(channel: websocketToNode) // RPCClientsRetainer.rpcClient(websocket: websocketToNode)
        let subscriberId = SubscriberId(uuid: UUID())
        let atom = sendAction.atom

        return Observable<NodeAction>.create { observer in
            var disposables = [Disposable]()

            let pushAtomAndObserveItsStatusDisposable = rpcClient
                .observeAtomStatusNotifications(subscriberId: subscriberId)
                .flatMap { statusNotification -> Observable<NodeAction> in

                    let statusAction = SubmitAtomActionStatus(sendAction: sendAction, node: node, statusNotification: statusNotification)

                    if statusNotification == .stored || !sendAction.isCompletingOnStoreOnly {
                        return Observable.of(
                            statusAction,
                            SubmitAtomActionCompleted(sendAction: sendAction, node: node)
                        )
                    } else { 
                        return Observable.just(statusAction)
                    }
                }.do(onSubscribe: {
                    let startObservingAtomStatusDisposable = rpcClient
                        .sendGetAtomStatusNotifications(atomIdentifier: atom.identifier(), subscriberId: subscriberId)
                        .andThen(rpcClient.pushAtom(atom))
                        .subscribe(
                            onCompleted: { observer.onNext(SubmitAtomActionRecived(sendAction: sendAction, node: node)) },
                            onError: { error in
                                if let submitAtomError = error as? SubmitAtomError {
                                    observer.onNext(
                                        SubmitAtomActionStatus(
                                            sendAction: sendAction,
                                            node: node,
                                            statusNotification: .notStored(reason: AtomNotStoredReason(.evictedInvalidAtom, error: submitAtomError)))
                                    )
                                    observer.onNext(
                                        SubmitAtomActionCompleted(sendAction: sendAction, node: node)
                                    )
                                } else {
                                    observer.onError(error)
                                }
                        }
                    )
                    disposables.append(startObservingAtomStatusDisposable)
                }).subscribe(observer)

            disposables.append(pushAtomAndObserveItsStatusDisposable)

            return Disposables.create(disposables)
        }
        .do(onDispose: { [unowned self] in
            rpcClient
                .closeAtomStatusNotifications(subscriberId: subscriberId)
                .andThen(
                    Observable<Int>.timer(delayFromCancelObservationOfAtomStatusToClosingWebsocket, scheduler: MainScheduler.instance).mapToVoid()
                        .flatMapCompletableVoid {
                            self.close(webSocketToNode: websocketToNode, useDelay: false)
                            return Completable.completed()
                    }
                ).subscribe().disposed(by: self.disposeBag)
        })
        .takeUntil(.inclusive) { $0 is SubmitAtomActionCompleted }

    }
}

public protocol FindANodeRequestAction: NodeAction {
    /// A shard space which must be intersected with a node's shard space to be selected, shards which can be picked amongst to find a matching supporting node
    var shards: Shards { get }
}

public struct FindANodeResultAction: NodeAction {
    public let node: Node /* selected node */
    public let request: FindANodeRequestAction
    
}
