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


public final class FetchAtomsEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsEpic.WebSockets
    private var cancellables = Set<AnyCancellable>()
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}

public extension FetchAtomsEpic {
    func epic(actions: CombineObservable<NodeAction>, networkState: CombineObservable<RadixNetworkState>) -> CombineObservable<NodeAction> {
        
//        var disposableMap: [UUID: CombineDisposable] = [:]
//
//        let fetch: CombineObservable<NodeAction> = actions
//            .ofType(FindANodeResultAction.self)
//            .filter { $0.request is FetchAtomsActionRequest }
//            .flatMap { [unowned self] (nodeFound: FindANodeResultAction) -> CombineObservable<NodeAction> in
//
//                let node = nodeFound.node
//                let fetchAtomsActionRequest = castOrKill(instance: nodeFound.request, toType: FetchAtomsActionRequest.self)
//                let uuid = fetchAtomsActionRequest.uuid
//
//                var fetchDisposable: CombineDisposable?
//                let atomsObs = CombineObservable<NodeAction>.create { observer in
//                    fetchCombineDisposable = self.fetchAtoms(from: node, request: fetchAtomsActionRequest).subscribe(observer)
//                    return CombineDisposables.create()
//                }
//
//                return self.waitForConnection(toNode: node)
//                    .andThen(atomsObs)
//                    .do(onSubscribe: { disposableMap[uuid] = fetchDisposable })
//        }
//
//        let cancelFetch: CombineObservable<NodeAction> = actions
//            .ofType(FetchAtomsActionCancel.self)
//            .do(onNext: { disposableMap.removeValue(forKey: $0.uuid)?.dispose() })
//            .ignoreElementsObservable().map { $0 }
//
//        return CombineObservable.merge(cancelFetch, fetch)
        
        combineMigrationInProgress()
    }
}

//private extension FetchAtomsEpic {
//    func fetchAtoms(from node: Node, request: FetchAtomsActionRequest) -> CombineObservable<NodeAction> {
//        let webSocketToNode = webSockets.webSocket(to: node, shouldConnect: false)
//        let rpcClient = DefaultRPCClient(channel: webSocketToNode)
//        let uuid = request.uuid
//        let subscriberIdFromUuid = SubscriberId(uuid: uuid)
//        let address = request.address
//
//        return CombineObservable.create { observer in
//
//            observer.onNext(FetchAtomsActionSubscribe(address: address, node: node, uuid: uuid))
//
//            var disposables = [CombineDisposable]()
//
//            let atomObservationsCombineDisposable = rpcClient.observeAtoms(subscriberId: subscriberIdFromUuid)
//                .map { observation in FetchAtomsActionObservation(address: address, node: node, atomObservation: observation, uuid: uuid) }
//                .subscribe(observer)
//
//            disposables.append(atomObservationsCombineDisposable)
//
//            let sendAtomsSubscribeDisposable = rpcClient.sendAtomsSubscribe(to: address, subscriberId: subscriberIdFromUuid).subscribe()
//
//            disposables.append(sendAtomsSubscribeDisposable)
//            return CombineDisposables.create(disposables)
//        }.do(onDispose: { [unowned self] in
//            rpcClient.cancelAtomsSubscription(subscriberId: subscriberIdFromUuid)
//                .andThen(
//                    CombineObservable<Int>.timer(delayFromCancelObservationOfAtomStatusToClosingWebsocket, scheduler: MainScheduler.instance).mapToVoid()
//                        .flatMapCompletableVoid {
//                            self.close(webSocketToNode: webSocketToNode, useDelay: false)
//                            return CombineCompletable.completed()
//                    }
//                ).catchError { errorToSupress in
//                    log.error("Supressing error: \(errorToSupress)")
//                    return CombineCompletable.completed()
//                }.subscribe().disposed(by: self.disposeBag)
//        })
//    }
//}
