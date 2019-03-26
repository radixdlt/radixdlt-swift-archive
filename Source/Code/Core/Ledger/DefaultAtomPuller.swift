//
//  DefaultAtomPuller.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultAtomPuller: AtomPuller {
    public typealias FetchAtom = (Address) -> Observable<AtomObservation>
    public typealias StoreAtom = (AtomObservation, Address) -> Void
    
    private let cache = Cache<Address, Observable<AtomObservation>>()
    private let fetcher: FetchAtom
    private let storeAtom: StoreAtom
    
    init(fetcher: @escaping FetchAtom, storeAtom: @escaping StoreAtom) {
        self.fetcher = fetcher
        self.storeAtom = storeAtom
    }
}

public extension DefaultAtomPuller {
    convenience init(puller: (AtomPuller & AnyObject), storeAtom: @escaping StoreAtom) {
        self.init(
            fetcher: { [unowned puller] in puller.pull(from: $0) },
            storeAtom: storeAtom
        )
    }
}

// MARK: AtomPuller
public extension DefaultAtomPuller {
    func pull(from address: Address) -> Observable<AtomObservation> {
        if let value = cache.value(for: address) {
            return value
        } else {
            return fetcher(address).do(onNext: { [unowned self] in
                self.storeAtom($0, address)
            })
                // https://github.com/ReactiveX/RxSwift/blob/master/Documentation/GettingStarted.md#sharing-subscription-and-share-operator
                .share(replay: 1) // analogue to: replay(1).refCount()
        }
    }
}
