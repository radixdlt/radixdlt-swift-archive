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

// MARK: - Observing RPC Responses
public extension DefaultRPCClient {
    func observeAtoms(subscriberId: SubscriberId) -> Observable<AtomObservation> {
        return observe(notification: .subscribeUpdate, subscriberId: subscriberId, responseType: AtomSubscriptionUpdate.self)
            .map { $0.toAtomObservation() }
            .flatMap { (atomObservations: [AtomObservation]) -> Observable<AtomObservation> in
                return Observable.from(atomObservations)
        }
    }
    
    func observeAtomStatusNotifications(subscriberId: SubscriberId) -> Observable<AtomStatusNotification> {
        return self.observe(notification: .observeAtomStatusNotifications, subscriberId: subscriberId, responseType: AtomStatusNotification.self)
    }
}

// MARK: - Make RPC Requests

// MARK: - Single's
public extension DefaultRPCClient {
    func getNetworkInfo() -> Single<RadixSystem> {
        return make(request: .getNetworkInfo)
    }
    
    func getLivePeers() -> Single<[NodeInfo]> {
        return make(request: .getLivePeers)
    }

    func getUniverseConfig() -> Single<UniverseConfig> {
        return make(request: .getUniverse)
    }
    
    func statusOfAtom(withIdentifier atomIdentifier: AtomIdentifier) -> Single<AtomStatus> {
        return make(request: .getAtomStatus(atomIdentifier: atomIdentifier))
    }
}

// MARK: - Completable
public extension DefaultRPCClient {
    func pushAtom(_ atom: SignedAtom) -> Completable {
        return makeCompletableMapError(request: .submitAtom(atom: atom)) { SubmitAtomError(rpcError: $0) }
    }
}

// MARK: - Send Request for STARTING Subscribing To Some Notification
public extension DefaultRPCClient {
    
    func sendAtomsSubscribe(to address: Address, subscriberId: SubscriberId) -> Completable {
        return sendStartSubscription(request: .subscribe(to: address, subscriberId: subscriberId))
    }
    
    func sendGetAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId) -> Completable {
        return sendStartSubscription(request: .getAtomStatusNotifications(atomIdentifier: atomIdentifier, subscriberId: subscriberId))
    }
}

// MARK: - Send Request for CLOSING Subscribing To Some Notification
public extension DefaultRPCClient {
    func closeAtomStatusNotifications(subscriberId: SubscriberId) -> Completable {
        return sendCancelSubscription(request: .closeAtomStatusNotifications(subscriberId: subscriberId))
    }
    
    func cancelAtomsSubscription(subscriberId: SubscriberId) -> Completable {
        return sendCancelSubscription(request: .unsubscribe(subscriberId: subscriberId))
    }
}

