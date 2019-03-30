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
    
    func testGetBalanceOverWS() {
        guard let apiClient = makeApiClient() else { return }
        
        let atomSubscriptionsObservable = apiClient.balance(forAddress: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor", token: TokenDefinitionReference(address: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor", symbol: "XRD"))
        
        // `take()` operator is absolutely crucial, read "Waiting on non-completing sequences": http://rx-marin.com/post/rxblocking-part1/
        let balance: TokenBalance = try! atomSubscriptionsObservable.take(1).toBlocking(timeout: 1).first()!
        
        XCTAssertEqual(balance.amount.signedAmount.description, "1000000000000000000000000000")
    }
}
