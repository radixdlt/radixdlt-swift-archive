//
//  ObservableType+ValidAtoms.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType where E == AtomObservation {
    /// Filters out only valid atoms
    func validAtoms() -> Observable<E> {
        // Trivial filtering, allow all, update according to: https://radixdlt.atlassian.net/browse/RLAU-508
        return filter({ _ in true })
    }
}
