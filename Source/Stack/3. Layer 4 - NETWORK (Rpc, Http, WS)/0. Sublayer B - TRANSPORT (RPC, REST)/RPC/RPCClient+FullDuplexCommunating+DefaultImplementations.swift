//
//  RPCClient+FullDuplexCommunating.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

// MARK: - Default Implementation
public extension NodeInfoRequesting where Self: FullDuplexCommunicating {
    func getInfo() -> Single<NodeInfo> {
        return make(request: .getInfo).asSingle()
    }
}

public extension LivePeersRequesting where Self: FullDuplexCommunicating {
    func getLivePeers() -> Single<[NodeInfo]> {
        return make(request: .getLivePeers).asSingle()
    }
}

public extension UniverseConfigRequesting where Self: FullDuplexCommunicating {
    func getUniverseConfig() -> Single<UniverseConfig> {
        return make(request: .getUniverse).asSingle()
    }
}

public extension AtomStatusObservationRequesting where Self: FullDuplexCommunicating {
    func sendGetAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId) -> Completable {
        return makeCompletable(request: .getAtomStatusNotifications(atomIdentifier: atomIdentifier, subscriberId: subscriberId))
    }
}

public extension AtomStatusObservationCancelling where Self: FullDuplexCommunicating {
    func closeAtomStatusNotifications(subscriberId: SubscriberId) -> Completable {
        implementMe()
    }
}

public extension AtomsByAddressSubscribing where Self: FullDuplexCommunicating {
    func sendAtomsSubscribe(to address: Address, subscriberId: SubscriberId) -> Completable {
        return make(request: .subscribe(to: address, subscriberId: subscriberId), resoponseType: AtomSubscription.self)
            .map { subscription -> AtomSubscription in
                if let startSubscription = subscription.startOrCancel, !startSubscription.success {
                    throw RPCClientError.failedToStartAtomSubscription
                }
                return subscription
            }.ignoreElements()
    }
    
    func observeAtoms(subscriberId: SubscriberId) -> Observable<AtomObservation> {
        return observe(notification: RPCNotification.subscribeUpdate, subscriberId: subscriberId, responseType: AtomSubscription.self)
            .map { $0.update }.filterNil()
            .map { $0.toAtomObservation() }
            .flatMap { (atomObservations: [AtomObservation]) -> Observable<AtomObservation> in
                return Observable.from(atomObservations)
            }
    }
}

public extension AtomStatusObserving where Self: FullDuplexCommunicating {
    func observeAtomStatusNotifications(subscriberId: SubscriberId) -> Observable<AtomStatusNotification> {
        return self.observe(notification: RPCNotification.observeAtomStatusNotifications, subscriberId: subscriberId, responseType: AtomStatusNotification.self)
    }
}

public extension AtomStatusChecking where Self: FullDuplexCommunicating {
    func statusOfAtom(withIdentifier atomIdentifier: AtomIdentifier) -> Single<AtomStatus> {
        return make(request: RPCRootRequest.getAtomStatus(atomIdentifier: atomIdentifier)).asSingle()
    }
}

public extension AtomSubscriptionCancelling where Self: FullDuplexCommunicating {
    func cancelAtomsSubscription(subscriberId: SubscriberId) -> Completable {
        return make(request: .unsubscribe(subscriberId: subscriberId))
            .map { (subscription: AtomSubscription) -> AtomSubscription in
                guard let cancellation = subscription.startOrCancel, cancellation.success else {
                    throw RPCClientError.failedToCancelAtomSubscription
                }
                
                return subscription
        }.ignoreElements()
    }
}

public enum RPCClientError: Swift.Error, Equatable {
    case failedToCancelAtomSubscription
    case failedToStartAtomSubscription
}

public extension AtomSubmitting where Self: FullDuplexCommunicating {
    func pushAtom(_ atom: SignedAtom) -> Completable {
        return makeCompletableMapError(request: .submitAtom(atom: atom)) { SubmitAtomError(rpcError: $0) }
    }
}
