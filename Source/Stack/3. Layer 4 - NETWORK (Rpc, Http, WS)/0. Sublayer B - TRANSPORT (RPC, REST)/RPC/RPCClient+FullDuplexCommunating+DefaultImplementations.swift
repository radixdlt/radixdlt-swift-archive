//
//  RPCClient+FullDuplexCommunating.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - Default Implementation
public extension NodeInfoRequesting where Self: FullDuplexCommunicating {
    func getInfo() -> SingleWanted<NodeInfo> {
        return make(request: .getInfo)
    }
}

public extension LivePeersRequesting where Self: FullDuplexCommunicating {
    func getLivePeers() -> SingleWanted<[NodeInfo]> {
        return make(request: .getLivePeers)
    }
}

public extension UniverseConfigRequesting where Self: FullDuplexCommunicating {
    func getUniverseConfig() -> SingleWanted<UniverseConfig> {
        return make(request: .getUniverse)
    }
}

public extension AtomsByAddressSubscribing where Self: FullDuplexCommunicating {
    func subscribe(to address: Address, subscriberId: SubscriberId) -> Observable<AtomSubscription> {
        return make(request: .subscribe(to: address, subscriberId: subscriberId))
    }
}

public extension AtomStatusObserving where Self: FullDuplexCommunicating {
    func observeAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId) -> Observable<AtomStatusNotification> {
        return make(request: .getAtomStatusNotifications(atomIdentifier: atomIdentifier, subscriberId: subscriberId))
    }
}

public extension AtomStatusChecking where Self: FullDuplexCommunicating {
    func statusOfAtom(withIdentifier atomIdentifier: AtomIdentifier) -> SingleWanted<AtomStatus> {
        return make(request: RPCRootRequest.getAtomStatus(atomIdentifier: atomIdentifier))
    }
}

public extension AtomSubscriptionCancelling where Self: FullDuplexCommunicating {
    func unsubscribe(subscriberId: SubscriberId) -> Observable<AtomSubscriptionStartOrCancel> {
        return make(request: .unsubscribe(subscriberId: subscriberId))
            .map { (subscription: AtomSubscription) -> AtomSubscriptionStartOrCancel in
                guard let cancellation = subscription.startOrCancel else {
                    incorrectImplementation("Should have received cancel, but got \(subscription)")
                }
                return cancellation
            }
        }
}

public extension AtomSubmitting where Self: FullDuplexCommunicating {
    func submit(atom: SignedAtom) -> CompletableWanted {
        return makeVoid(request: .submitAtom(atom: atom))
    }
}
