//
//  AccountBalancing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AccountBalancing {
    func getBalances(for address: Address) -> Observable<BalancePerToken>
    func getBalances(for address: Address, ofToken token: ResourceIdentifier) -> Observable<TokenBalance>
}

// MARK: - Default Implementation
public extension AccountBalancing {
 
    func getBalances(for address: Address, ofToken token: ResourceIdentifier) -> Observable<TokenBalance> {
        return getBalances(for: address).map {
            $0.balanceOrZero(of: token, address: address)
        }
    }
}

public extension AccountBalancing where Self: IdentityHolder {
    func getMyBalances() -> Observable<BalancePerToken> {
        let myAddress = identity.address
        return getBalances(for: myAddress)
    }
    
    func getMyBalance(of tokenIdentifier: ResourceIdentifier) -> Observable<TokenBalance> {
        let myAddress = identity.address
        return getMyBalances().map {
            $0.balanceOrZero(of: tokenIdentifier, address: myAddress)
        }
    }
}

// MARK: - AccountBalancing + NodeInteracting
public extension AccountBalancing where Self: NodeInteractingSubscribe {
    func getBalances(for address: Address) -> Observable<BalancePerToken> {
        let atoms = nodeSubscriber.subscribe(to: address)
            .map { (atomUpdates: [AtomUpdate]) -> [Atom] in
                return atomUpdates.compactMap {
                    guard $0.action == .store else { return nil }
                    return $0.atom
                }
        }
        return TokenBalanceReducer().reduce(atoms: atoms)
    }
}
