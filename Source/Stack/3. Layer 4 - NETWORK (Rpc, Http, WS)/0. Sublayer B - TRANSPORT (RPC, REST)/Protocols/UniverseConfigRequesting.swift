//
//  UniverseConfigRequesting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

/// Typealias marking that we want to use trait `Single`, but due to failing tests, we are forced to retort to `Observable`
public typealias SingleWanted<E> = Observable<E>

public protocol UniverseConfigRequesting {
    func getUniverseConfig() -> SingleWanted<UniverseConfig>
}
