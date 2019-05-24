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
        return makeRequest(method: .getInfo)
    }
}

public extension LivePeersRequesting where Self: FullDuplexCommunicating {
    func getLivePeers() -> SingleWanted<[NodeInfo]> {
        return makeRequest(method: .getLivePeers)
    }
}

public extension UniverseConfigRequesting where Self: FullDuplexCommunicating {
    func getUniverseConfig() -> SingleWanted<UniverseConfig> {
        return makeRequest(method: .getUniverse)
    }
}

public extension AtomsByAddressSubscribing where Self: FullDuplexCommunicating {
    func subscribe(to address: Address, subscriberId: SubscriberId) -> Observable<AtomSubscription> {
        return makeRequest(method: .subscribe(to: address, subscriberId: subscriberId))
    }
}

public extension AtomSubscriptionCancelling where Self: FullDuplexCommunicating {
    func unsubscribe(subscriberId: SubscriberId) -> Observable<AtomSubscriptionStartOrCancel> {
        return makeRequest(method: .unsubscribe(subscriberId: subscriberId)).map { (subscription: AtomSubscription) -> AtomSubscriptionStartOrCancel in
            guard let cancellation = subscription.startOrCancel else {
                incorrectImplementation("Should have received cancel, but got \(subscription)")
            }
            return cancellation
        }
    }
}

public extension AtomSubmitting where Self: FullDuplexCommunicating {
    func submit(atom: SignedAtom, subscriberId: SubscriberId) -> Observable<AtomSubscription> {
        return makeRequest(method: .submitAndSubscribe(atom: atom, subscriberId: subscriberId))
    }
}
