//
//  GetBalanceTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking

class GetBalanceOverWebSocketsTest: WebsocketTest {
    
    private var address: Address!
    private var xrd: ResourceIdentifier!
    
    override func setUp() {
        super.setUp()
        self.address = "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor"
    }
    
    func testGetBalanceOverWS() {
        let application = DefaultRadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhost, identity: AbstractIdentity())
        guard let balance = application.balanceOfNativeTokensOrZero(for: address).blockingTakeFirst() else { return }
        
        XCTAssertEqual(balance.amount.description, "1000000000000000000000000000")
    }
}
