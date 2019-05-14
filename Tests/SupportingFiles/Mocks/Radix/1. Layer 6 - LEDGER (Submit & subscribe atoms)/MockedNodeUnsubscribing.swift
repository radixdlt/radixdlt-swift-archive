//
//  MockedNodeUnsubscribing.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import RxSwift

struct MockedNodeUnsubscribing: NodeInteractionUnsubscribing {
    func unsubscribe(from address: Address) -> Completable {
        abstract
    }
    
    func unsubscribeAll() -> Completable {
        abstract
    }
}
