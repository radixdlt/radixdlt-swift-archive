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

let delayFromCancelObservationOfAtomStatusToClosingWebsocket = DispatchTimeInterval.seconds(5)

public final class SubmitAtomEpic: RadixNetworkWebSocketsEpic {
    
    public let webSockets: WebSocketsManager
    private var cancellables = Set<AnyCancellable>()
    
    public init(webSockets: WebSocketsManager) {
        self.webSockets = webSockets
    }
}

public extension SubmitAtomEpic {
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
//        let foundNode: AnyPublisher<NodeAction, Never> = actions
//            .compactMap(typeAs: FindANodeResultAction.self)
//            .filter { $0.request is SubmitAtomActionRequest }
//            .map {
//                let request = castOrKill(instance: $0.request, toType: SubmitAtomActionRequest.self)
//                return SubmitAtomActionSend(request: request, node: $0.node)
//        }
//
//        let submitToNode: AnyPublisher<NodeAction, Never> = actions
//            .compactMap(typeAs: SubmitAtomActionSend.self)
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

    func submitAtom(sendAction: SubmitAtomActionSend, toNode node: Node) -> AnyPublisher<NodeAction, Never> {
//        let webSocketToNode = webSockets.webSocket(to: node, shouldConnect: false)
//        let rpcClient =  DefaultRPCClient(channel: webSocketToNode)
//        let subscriberId = SubscriberId(uuid: UUID())
//        let atom = sendAction.atom
//
//        return AnyPublisher<NodeAction, Never>.create { observer in
//            var disposables = [CombineDisposable]()
//
//            let pushAtomAndObserveItsStatusCombineDisposable = rpcClient
//                .observeAtomStatusNotifications(subscriberId: subscriberId)
//                .flatMap { statusEvent -> AnyPublisher<NodeAction, Never> in
//                    let statusAction = SubmitAtomActionStatus(sendAction: sendAction, node: node, statusEvent: statusEvent)
//
//                    if statusEvent == .stored || !sendAction.isCompletingOnStoreOnly {
//                        return CombineObservable.of(
//                            statusAction,
//                            SubmitAtomActionCompleted(sendAction: sendAction, node: node)
//                        )
//                    } else {
//                        return Just(statusAction)
//                    }
//                }.do(onSubscribe: {
//                    let startObservingAtomStatusCombineDisposable = rpcClient
//                        .sendGetAtomStatusNotifications(atomIdentifier: atom.identifier(), subscriberId: subscriberId)
//                        .andThen(rpcClient.pushAtom(atom))
//                        .subscribe(
//                            onCompleted: { observer.send(SubmitAtomActionReceived(sendAction: sendAction, node: node)) },
//                            onError: { error in
//                                if let submitAtomError = error as? SubmitAtomError {
//                                    observer.send(
//                                        SubmitAtomActionStatus(
//                                            sendAction: sendAction,
//                                            node: node,
//                                            statusEvent: .notStored(reason: AtomNotStoredReason(.evictedInvalidAtom, error: submitAtomError)))
//                                    )
//                                    observer.send(
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
//            return CombineDisposables.create(disposables)
//        }
//        .do(onDispose: { [unowned self] in
//            rpcClient
//                .closeAtomStatusNotifications(subscriberId: subscriberId)
//                .andThen(
//                    AnyPublisher<Int, Never>.timer(delayFromCancelObservationOfAtomStatusToClosingWebsocket, scheduler: MainScheduler.instance).mapToVoid()
//                        .flatMapCompletableVoid {
//                            self.close(webSocketToNode: webSocketToNode, useDelay: false)
//                            return Completable.completed()
//                    }
//                ).subscribe().disposed(by: self.disposeBag)
//        })
//        .takeUntil(.inclusive) { $0 is SubmitAtomActionCompleted }
        
        combineMigrationInProgress()
    }
}

///  A dispatch action request for a connected node with some given shards
public protocol FindANodeRequestAction: NodeAction {
    /// A shard space which must be intersected with a node's shard space to be selected, shards which can be picked amongst to find a matching supporting node
    var shards: Shards { get }
}

/// The result of a `FindANodeRequestAction` action
public struct FindANodeResultAction: NodeAction {
    
    /// The found / selected node
    public let node: Node
    
    /// The original request
    public let request: FindANodeRequestAction
    
}
