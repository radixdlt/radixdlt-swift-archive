//
//  NodeInteraction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol NodeInteraction {
    func subscribe(to address: Address) -> Observable<[AtomUpdate]>
    func submit(atom: SignedAtom) -> Completable
    func unsubscribe(from address: Address) -> Completable
    func unsubscribeAll() -> Completable
}
