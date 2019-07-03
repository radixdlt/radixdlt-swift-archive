//
//  NodeInteraction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol NodeInteractionSubscribing {
    func subscribe(to address: Address) -> Observable<[AtomObservation]>
}

public protocol NodeInteractionUnsubscribing {
    func unsubscribe(from address: Address) -> Completable
    func unsubscribeAll() -> Completable
}

public protocol NodeInteractionSubmitting {
    func submit(atom: SignedAtom) -> Completable
}

public typealias NodeInteraction =
    NodeInteractionSubscribing &
    NodeInteractionUnsubscribing &
    NodeInteractionSubmitting
