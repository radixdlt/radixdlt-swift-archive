//
//  AtomQuerying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

/// In Javascript see `RadixAtomUpdate` in Java see `AtomObservation`
public struct AtomUpdate {
    public let action: AtomEvent.Type
    public let atom: Atom
    public let isHead: Bool
}

public protocol AtomQuerying {
    func getAtoms(for address: Address) -> Observable<AtomSubscription>
}
