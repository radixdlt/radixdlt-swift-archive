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
public extension RPCClient where Self: FullDuplexCommunicating {
    func getInfo() -> SingleWanted<NodeInfo> {
        return makeRequest(method: .getInfo)
    }
    
    func getLivePeers() -> SingleWanted<[NodeInfo]> {
        return makeRequest(method: .getLivePeers)
    }
    
    func getUniverseConfig() -> SingleWanted<UniverseConfig> {
        return makeRequest(method: .getUniverse)
    }
    
    func subscribe(to address: Address, subscriberId: SubscriberId) -> Observable<AtomSubscription> {
        return makeRequest(method: .subscribe(to: address, subscriberId: subscriberId))
    }
    
    func submit(atom: SignedAtom, subscriberId: SubscriberId) -> Observable<AtomSubscription> {
        return makeRequest(method: .submitAndSubscribe(atom: atom, subscriberId: subscriberId))
    }
}
