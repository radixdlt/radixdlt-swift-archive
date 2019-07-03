//
//  Completable_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.Trait == CompletableTrait, Self.Element == Never {
    static func completed() -> Completable {
        return Completable.empty() // the equivalence of RxJava `Completable.completed()`
    }
}
