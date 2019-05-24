//
//  SubscriptionTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK
import RxSwift

// RLAU 1092
class SubscriptionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    // AC0
    func testSubscribeToAtomsForAddress() {
        // GIVEN
        // A node interaction ("Ledger")
        let nodeInteraction = DefaultNodeInteraction(NodeDiscoveryHardCoded.localhost)

        // WHEN
        // I subscribe to genesis address
        switch nodeInteraction.subscribe(to: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor").take(2).toBlocking(timeout: 2).materialize() {
        case .completed(let elements):
            // THEN
            // I see that I get two updates (one `isHead` false, one `isHead: true`)
            XCTAssertEqual(elements.count, 2)
           
        case .failed(_, let error): XCTFail("error: \(error)")
        }

    }

}

private let magic: Magic = 63799298

private extension RadixIdentity {
    init(privateKey: PrivateKey) {
        self.init(private: privateKey, magic: magic)
    }
    
    init() {
        self.init(magic: magic)
    }
}
