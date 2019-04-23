//
//  Transacting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

/// Type that is can make transactions of different types between Radix accounts
public protocol Transacting {
    func makeTransaction(_ transaction: Transaction) -> Completable
}

// MARK: - Transacting + NodeInteracting => Default Impl
public extension Transacting where Self: NodeInteracting {
    func makeTransaction(_ transaction: Transaction) -> Completable {
        implementMe
    }
}
