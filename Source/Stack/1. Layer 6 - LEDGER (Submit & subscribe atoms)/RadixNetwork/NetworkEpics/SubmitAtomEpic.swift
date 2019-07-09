//
//  SubmitAtomEpic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class SubmitAtomEpic: NetworkWebsocketEpic {
    
    public let webSockets: WebSocketsEpic.WebSockets
    private let disposeBag = DisposeBag()
    private var disposeBagsForSendAtomFlowBySubscriberId: [SubscriberId: DisposeBag] = [:]
    private var publishSubjectsForSendAtomFlowBySubscriberId: [SubscriberId: PublishSubject<NodeAction>] = [:]
    
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
        }.do(
            onNext: { log.debug("🕵🏼‍♂️⭐️ next: \($0)") },
            onError: { log.debug("🕵🏼‍♂️💩 error: \($0)") },
            onCompleted: { log.debug("🕵🏼‍♂️✅ completed") },
            onSubscribed: { log.debug("🕵🏼‍♂️🎧 subscribed") },
            onDispose: { log.debug("🕵🏼‍♂️🗑 dispose") }
        )
        
        let submitToNode: Observable<NodeAction> = actions
            .ofType(SubmitAtomActionSend.self)
            .flatMap { [unowned self] in
                self.waitForConnection(toNode: $0.node)
                    .andThen(self.submitAtom(sendAction: $0, toNode: $0.node))
        }.do(
            onNext: { log.debug("🚀⭐️ next: \($0)") },
            onError: { log.debug("🚀💩 error: \($0)") },
            onCompleted: { log.debug("🚀✅ completed") },
            onSubscribed: { log.debug("🚀🎧 subscribed") },
            onDispose: { log.debug("🚀🗑 dispose") }
        )
        
        return Observable.merge(
            foundNode,
            submitToNode
        )
    }
}

internal let delayFromCancelObservationOfAtomStatusToClosingWebsocket = DispatchTimeInterval.seconds(5)

internal func goodNewsNowImplementRemainingLogicHere(
    _ reason: String? = nil,
    _ file: String = #file,
    _ line: Int = #line
    ) -> Never {
    let reasonString = reason != nil ? "`\(reason!)`" : ""
    let message = "Good news, now implement remaining logic here: \(reasonString),\nIn file: \(file), line: \(line)"
    fatalError(message)
}

// swiftlint:disable function_body_length
private extension SubmitAtomEpic {
    
//    func submitAtom(sendAction: SubmitAtomActionSend, toNode node: Node) -> Observable<NodeAction> {
//        let websocketToNode = webSockets.webSocket(to: node, shouldConnect: false)
//        let rpcClient =  DefaultRPCClient(channel: websocketToNode) // RPCClientsRetainer.rpcClient(websocket: websocketToNode)
//        let subscriberId = SubscriberId(uuid: UUID())
//        let atom = sendAction.atom
//        let isCompletingOnStoreOnly = sendAction.isCompletingOnStoreOnly
//
//        log.debug("🎉 Subscriber id: \(subscriberId), atomId: \(atom.identifier())")
//        let flowDisposeBag = DisposeBag()
//        disposeBagsForSendAtomFlowBySubscriberId[subscriberId] = flowDisposeBag
//        let nodeActionSubject = PublishSubject<NodeAction>()
//        publishSubjectsForSendAtomFlowBySubscriberId[subscriberId] = nodeActionSubject
//
//        rpcClient.observeAtomStatusNotifications(subscriberId: subscriberId)
//            .do(
//                onNext: { (atomStatusNotification: AtomStatusNotification) in
//                    log.debug("🎉 Got AtomStatusNotification: \(atomStatusNotification)")
//                    nodeActionSubject.onNext(
//                        SubmitAtomActionStatus(sendAction: sendAction, node: node, statusNotification: atomStatusNotification)
//                    )
//
//                    if atomStatusNotification == .stored || !isCompletingOnStoreOnly {
//                        nodeActionSubject.onNext(
//                            SubmitAtomActionCompleted(sendAction: sendAction, node: node)
//                        )
//                    }
//                },
//                onSubscribed: {
//                    rpcClient.sendGetAtomStatusNotifications(atomIdentifier: atom.identifier(), subscriberId: subscriberId)
//                        .andThen(
//                            rpcClient.pushAtom(atom)
//                        ).subscribe(
//                            onCompleted: { nodeActionSubject.onNext(SubmitAtomActionRecived(sendAction: sendAction, node: node)) },
//                            onError: { error in
//                                if let submitAtomError = error as? SubmitAtomError {
//                                    nodeActionSubject.onNext(
//                                        SubmitAtomActionStatus(
//                                            sendAction: sendAction,
//                                            node: node,
//                                            statusNotification: .notStored(reason: AtomNotStoredReason(.evictedInvalidAtom, error: submitAtomError)))
//                                    )
//                                    nodeActionSubject.onNext(
//                                        SubmitAtomActionCompleted(sendAction: sendAction, node: node)
//                                    )
//                                } else {
//                                    nodeActionSubject.onError(error)
//                                }
//                            }
//                        ).disposed(by: flowDisposeBag)
//            },
//                onDispose: {
//
//                    rpcClient
//                        .closeAtomStatusNotifications(subscriberId: subscriberId)
//                        .andThen(
//                            Observable<Int>.timer(delayFromCancelObservationOfAtomStatusToClosingWebsocket, scheduler: MainScheduler.instance).mapToVoid()
//                                .flatMapCompletableVoid { [unowned self] in
//                                    log.debug("✅ Cancelled AtomStatusNotficiation, now closing websocket and cleaning up subjects and disposebag")
//                                    self.close(webSocketToNode: websocketToNode, useDelay: false)
//                                    self.disposeBagsForSendAtomFlowBySubscriberId[subscriberId] = nil
//                                    self.publishSubjectsForSendAtomFlowBySubscriberId[subscriberId] = nil
//                                    return Completable.completed()
//                            }
//                        ).subscribe().disposed(by: flowDisposeBag)
//
//                }
//            ).subscribe().disposed(by: flowDisposeBag)
//
//        return nodeActionSubject.asObservable().takeUntil(.inclusive) { $0 is SubmitAtomActionCompleted }
//
//    }
    
    func submitAtom(sendAction: SubmitAtomActionSend, toNode node: Node) -> Observable<NodeAction> {
        let websocketToNode = webSockets.webSocket(to: node, shouldConnect: false)
        let rpcClient =  DefaultRPCClient(channel: websocketToNode) // RPCClientsRetainer.rpcClient(websocket: websocketToNode)
        let subscriberId = SubscriberId(uuid: UUID())
        let atom = sendAction.atom
        log.debug("🎉 Subscriber id: \(subscriberId), atomId: \(atom.identifier().hex.suffix(4)), sendActionUuid: \(sendAction.uuid.uuidString.suffix(4))")

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
            .do(
                onNext: { log.debug("🎉⭐️ next: \($0)") },
                onError: { log.debug("🎉💩 error: \($0)") },
                onCompleted: { log.debug("🎉✅ completed") },
                onSubscribed: { log.debug("🎉🎧 subscribed") },
                onDispose: { log.debug("🎉🗑 dispose") }
            )
        .takeUntil(.inclusive) { $0 is SubmitAtomActionCompleted }

    }
}

// swiftlint:enable function_body_length

public protocol FindANodeRequestAction: NodeAction {
    /// A shard space which must be intersected with a node's shard space to be selected, shards which can be picked amongst to find a matching supporting node
    var shards: Shards { get }
}

public struct FindANodeResultAction: NodeAction {
    public let node: Node /* selected node */
    public let request: FindANodeRequestAction
    
}
