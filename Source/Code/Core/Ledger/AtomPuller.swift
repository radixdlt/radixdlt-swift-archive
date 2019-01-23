//
//  AtomPuller.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomPuller {
    /// Fetches atoms and stores in an Atom Store
    func pull(from address: Address) -> Observable<AtomObservation>
}
