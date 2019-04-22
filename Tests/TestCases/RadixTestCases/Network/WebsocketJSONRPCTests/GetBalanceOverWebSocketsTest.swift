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
        self.xrd = ResourceIdentifier(address: address, name: "XRD")
    }
    
    func testGetBalanceOverWS() {
        guard let applicationClient = makeApplicationClient() else { return }
        guard let balance =  applicationClient.getBalances(for: address, ofToken: xrd).blockingTakeFirst() else { return }
        
        XCTAssertEqual(balance.amount.signedAmount.description, "1000000000000000000000000000")
    }
}
