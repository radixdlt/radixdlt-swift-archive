//
//  AccountBalancing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

//public struct AccountBalances {
//    public let account: Address
//    public let balances: TokenBalanceReferencesState
//}
//
//public extension AccountBalances {
//    func balance(of tokenIdentifier: ResourceIdentifier) -> AccountBalanceOf {
//
//        return AccountBalanceOf(
//            account: account,
//            balance: balances.balanceOrZero(of: tokenIdentifier, address: account)
//        )
//    }
//}
//
//public struct AccountBalanceOf {
//    public let account: Address
//    public let balance: TokenBalanceReferenceWithConsumables
//}
//
//public protocol AccountBalancing {
//    func getBalances(for address: Address) -> Observable<AccountBalances>
//    func getBalances(for address: Address, ofToken token: ResourceIdentifier) -> Observable<AccountBalanceOf>
//}
//
//// MARK: - Default Implementation
//public extension AccountBalancing {
//
//    func getBalances(for address: Address, ofToken token: ResourceIdentifier) -> Observable<AccountBalanceOf> {
//        return getBalances(for: address) .map { $0.balance(of: token) }
//    }
//}
//
//public extension AccountBalancing where Self: IdentityHolder {
//    func getMyBalances() -> Observable<AccountBalances> {
//        let myAddress = identity.address
//        return getBalances(for: myAddress)
//    }
//
//    func getMyBalance(of tokenIdentifier: ResourceIdentifier) -> Observable<AccountBalanceOf> {
//        return getMyBalances().map { $0.balance(of: tokenIdentifier) }
//    }
//}
//
//// MARK: - AccountBalancing + NodeInteracting
//public extension AccountBalancing where Self: NodeInteractingSubscribe {
//    func getBalances(for address: Address) -> Observable<AccountBalances> {
//        log.info("Getting balances for address: \(address)")
//        return nodeSubscriber.subscribe(to: address)
//            .storedAtomsOnly()
//            .map { $0.flatMap { $0.tokensBalances() }.filter { $0.address == address } }
//            .map { TokenBalanceReducer().reduce(tokenBalances: $0) }
//            .map { AccountBalances(account: address, balances: $0) }
//    }
//}
//

internal extension ObservableType where E == [AtomObservation] {
    func storedAtomsOnly() -> Observable<[Atom]> {
        return self.asObservable().map { (atomUpdates: [AtomObservation]) -> [Atom] in
            return atomUpdates.compactMap {
                guard $0.isStore else { return nil }
                return $0.atom
            }
        }
    }

    func storedAtomOnly() -> Observable<Atom> {
        return storedAtomsOnly().flatMap { (atoms: [Atom]) -> Observable<Atom> in
            return Observable<Atom>.from(atoms)
        }
    }
}
