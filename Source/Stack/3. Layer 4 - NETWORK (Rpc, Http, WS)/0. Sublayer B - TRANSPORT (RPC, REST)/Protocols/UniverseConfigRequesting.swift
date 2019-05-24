//
//  UniverseConfigRequesting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

/// Typealias of `Observable`, marking that we want to use trait `Single`, but due to failing tests, we are forced to retort to `Observable`. This will be addressed later
public typealias SingleWanted<E> = Observable<E>
/// Typealias of `Observable`, marking that we want to use trait `Completable`, but due to failing tests, we are forced to retort to `Observable`. This will be addressed later
public typealias CompletableWanted = Observable<Void>

public protocol UniverseConfigRequesting {
    func getUniverseConfig() -> SingleWanted<UniverseConfig>
}
