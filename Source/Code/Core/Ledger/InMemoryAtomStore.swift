//
//  InMemoryAtomStore.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class InMemoryAtomStore: AtomStore {
    private let cache = Cache<Address, ReplaySubject<AtomObservation>>()
}

public extension InMemoryAtomStore {
    func store(atom: AtomObservation, for address: Address) {
        subject(for: address).onNext(atom)
    }
}

// MARK: - AtomStore
public extension InMemoryAtomStore {
    func atoms(for address: Address) -> Observable<AtomObservation> {
        return subject(for: address).asObservable().distinctUntilChanged().flatMapLatest { atomObservation -> Observable<AtomObservation> in
            if atomObservation.isHead {
                return .just(atomObservation)
            } else {
                return Observable.just(atomObservation).validAtoms()
            }
        }
    }
}

// MARK: - Private
private extension InMemoryAtomStore {
    func subject(for address: Address) -> ReplaySubject<AtomObservation> {
        return cache.value(for: address) {
            ReplaySubject<AtomObservation>.createUnbounded()
        }
    }
}
