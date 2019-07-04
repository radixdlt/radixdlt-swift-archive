//
//  FetchAtomsEpic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

public final class FetchAtomsEpic: NetworkWebsocketEpic {
    public let webSockets: WebSocketsEpic.WebSockets
    private let disposeBag = DisposeBag()
    public init(webSockets: WebSocketsEpic.WebSockets) {
        self.webSockets = webSockets
    }
}

public extension FetchAtomsEpic {
    func epic(actions: Observable<NodeAction>, networkState: Observable<RadixNetworkState>) -> Observable<NodeAction> {
        
        var disposableMap: [UUID: Disposable] = [:]
        
        let fetch: Observable<NodeAction> = actions
            .ofType(FindANodeResultAction.self)
//            .filterMap {
//                guard let fetchAtomsRequest = $0.request as? FetchAtomsActionRequest else { return .ignore }
//                return RxSwiftExt.FilterMap<FetchAtomsActionRequest>.map(fetchAtomsRequest)
            .filter { $0.request is FetchAtomsActionRequest }
            .map {
               castOrKill(instance: $0.request, toType: FetchAtomsActionRequest.self) // TODO if this works, change to `filterMap`, do analogously in `SubmitAtomEpic`
            }.flatMap { [unowned self] (fetchAtomsActionRequest: FetchAtomsActionRequest) -> Observable<NodeAction> in
                let node = fetchAtomsActionRequest.node
                let uuid = fetchAtomsActionRequest.uuid
                
                var fetchDisposable: Disposable?
                let atomsObs = Observable<NodeAction>.create { observer in
                    fetchDisposable = self.fetchAtoms(from: node, request: fetchAtomsActionRequest).subscribe(observer)
                    return Disposables.create()
                }
                
                return self.waitForConnection(toNode: node)
                    .andThen(atomsObs)
                    .do(onSubscribe: { disposableMap[uuid] = fetchDisposable })
        }
        let cancelFetch: Observable<NodeAction> = actions
            .ofType(FetchAtomsActionCancel.self)
            .do(onNext: { disposableMap.removeValue(forKey: $0.uuid)?.dispose() })
            .ignoreElementsObservable().map { $0 }
        
        return Observable.merge(cancelFetch, fetch)
    }
}

private extension FetchAtomsEpic {
    func fetchAtoms(from node: Node, request: FetchAtomsActionRequest) -> Observable<NodeAction> {
        let webSocketToNode = webSockets.webSocket(to: node, shouldConnect: false)
        let rpcClient = DefaultRPCClient(channel: webSocketToNode)
        let uuid = request.uuid
        let subscriberIdFromUuid = SubscriberId(uuid: uuid)
        let address = request.address
        
        return Observable.create { observer in
            
            observer.onNext(FetchAtomsActionSubscribe(address: address, node: node, uuid: uuid))
            
            var disposables = [Disposable]()
            
            let atomObservationsDisposable = rpcClient.observeAtoms(subscriberId: subscriberIdFromUuid)
                .map { observation in FetchAtomsActionObservation(address: address, node: node, atomObservation: observation, uuid: uuid) }
                .subscribe(observer)
            
            disposables.append(atomObservationsDisposable)
            
            let sendAtomsSubscribeDisposable = rpcClient.sendAtomsSubscribe(to: address, subscriberId: subscriberIdFromUuid).subscribe()
            
            disposables.append(sendAtomsSubscribeDisposable)
            return Disposables.create(disposables)
        }.do(onDispose: { [unowned self] in
            rpcClient.cancelAtomsSubscription(subscriberId: subscriberIdFromUuid)
                .andThen(
                    Observable<Int>.timer(delayFromCancelObservationOfAtomStatusToClosingWebsocket, scheduler: MainScheduler.instance).mapToVoid()
                        .flatMapCompletableVoid {
                            self.close(webSocketToNode: webSocketToNode, useDelay: false)
                            return Completable.completed()
                    }
                ).catchError { errorToSupress in
                    log.error("Supressing error: \(errorToSupress)")
                    return Completable.completed()
                }.subscribe().disposed(by: self.disposeBag)
        })
    }
}
