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
    func subscribe(to address: Address) -> Observable<[AtomUpdate]>
}

public protocol NodeInteractionUnsubscribing {
    func unsubscribe(from address: Address) -> CompletableWanted
    func unsubscribeAll() -> CompletableWanted
}

public protocol NodeInteractionSubmitting {
    func submit(atom: SignedAtom) -> CompletableWanted
}

public typealias NodeInteraction =
    NodeInteractionSubscribing &
    NodeInteractionUnsubscribing &
    NodeInteractionSubmitting
