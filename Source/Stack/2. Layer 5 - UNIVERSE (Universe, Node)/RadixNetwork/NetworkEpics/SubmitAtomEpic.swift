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
import Combine

let delayFromCancelObservationOfAtomStatusToClosingWebsocket = DispatchTimeInterval.seconds(5)

public final class SubmitAtomEpic: NetworkWebsocketEpic {
    
    public let webSockets: WebSocketsEpic.WebSockets
    private let disposeBag = DisposeBag()
    
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}

public extension SubmitAtomEpic {
    func epic(actions: CombineObservable<NodeAction>, networkState: CombineObservable<RadixNetworkState>) -> CombineObservable<NodeAction> {
        
//        let foundNode: CombineObservable<NodeAction> = actions
//            .ofType(FindANodeResultAction.self)
//            .filter { $0.request is SubmitAtomActionRequest }
//            .map {
//                let request = castOrKill(instance: $0.request, toType: SubmitAtomActionRequest.self)
//                return SubmitAtomActionSend(request: request, node: $0.node)
//        }
//
//        let submitToNode: CombineObservable<NodeAction> = actions
//            .ofType(SubmitAtomActionSend.self)
//            .flatMap { [unowned self] in
//                self.waitForConnection(toNode: $0.node)
//                    .andThen(self.submitAtom(sendAction: $0, toNode: $0.node))
//        }
//
//        return CombineObservable.merge(
//            foundNode,
//            submitToNode
//        )
        combineMigrationInProgress()
    }
}

private extension SubmitAtomEpic {

    // swiftlint:disable:next function_body_length
    func submitAtom(sendAction: SubmitAtomActionSend, toNode node: Node) -> CombineObservable<NodeAction> {
//        let websocketToNode = webSockets.webSocket(to: node, shouldConnect: false)
//        let rpcClient =  DefaultRPCClient(channel: websocketToNode)
//        let subscriberId = SubscriberId(uuid: UUID())
//        let atom = sendAction.atom
//
//        return CombineObservable<NodeAction>.create { observer in
//            var disposables = [Disposable]()
//
//            let pushAtomAndObserveItsStatusDisposable = rpcClient
//                .observeAtomStatusNotifications(subscriberId: subscriberId)
//                .flatMap { statusEvent -> CombineObservable<NodeAction> in
//                    let statusAction = SubmitAtomActionStatus(sendAction: sendAction, node: node, statusEvent: statusEvent)
//
//                    if statusEvent == .stored || !sendAction.isCompletingOnStoreOnly {
//                        return CombineObservable.of(
//                            statusAction,
//                            SubmitAtomActionCompleted(sendAction: sendAction, node: node)
//                        )
//                    } else {
//                        return CombineObservable.just(statusAction)
//                    }
//                }.do(onSubscribe: {
//                    let startObservingAtomStatusDisposable = rpcClient
//                        .sendGetAtomStatusNotifications(atomIdentifier: atom.identifier(), subscriberId: subscriberId)
//                        .andThen(rpcClient.pushAtom(atom))
//                        .subscribe(
//                            onCompleted: { observer.onNext(SubmitAtomActionReceived(sendAction: sendAction, node: node)) },
//                            onError: { error in
//                                if let submitAtomError = error as? SubmitAtomError {
//                                    observer.onNext(
//                                        SubmitAtomActionStatus(
//                                            sendAction: sendAction,
//                                            node: node,
//                                            statusEvent: .notStored(reason: AtomNotStoredReason(.evictedInvalidAtom, error: submitAtomError)))
//                                    )
//                                    observer.onNext(
//                                        SubmitAtomActionCompleted(sendAction: sendAction, node: node)
//                                    )
//                                } else {
//                                    observer.onError(error)
//                                }
//                        }
//                    )
//                    disposables.append(startObservingAtomStatusDisposable)
//                }).subscribe(observer)
//
//            disposables.append(pushAtomAndObserveItsStatusDisposable)
//
//            return Disposables.create(disposables)
//        }
//        .do(onDispose: { [unowned self] in
//            rpcClient
//                .closeAtomStatusNotifications(subscriberId: subscriberId)
//                .andThen(
//                    CombineObservable<Int>.timer(delayFromCancelObservationOfAtomStatusToClosingWebsocket, scheduler: MainScheduler.instance).mapToVoid()
//                        .flatMapCompletableVoid {
//                            self.close(webSocketToNode: websocketToNode, useDelay: false)
//                            return CombineCompletable.completed()
//                    }
//                ).subscribe().disposed(by: self.disposeBag)
//        })
//        .takeUntil(.inclusive) { $0 is SubmitAtomActionCompleted }
        
        combineMigrationInProgress()
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
