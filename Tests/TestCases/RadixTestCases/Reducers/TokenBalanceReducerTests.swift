//
//  TokenBalanceReducerTests.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxTest
import RxBlocking
import RxSwift

class TokenBalanceReducerTests: XCTestCase {
    func testSimpleBalance() {
        let minted = mintedToken(10)
        let reducer = TokenBalanceReducer()
        let balances = reducer.reduce(minted)
        let balance = balances[xrd]
        XCTAssertEqual(balance?.amount.signedAmount, 10)
    }
    
    func testMultipleMintedTokens() {
        // Initializes test scheduler. Test scheduler implements virtual time that is detached from local machine clock
        // This enables running the simulation as fast as possible and proving that all events have been handled.
        let scheduler = TestScheduler(initialClock: 0)
        
        // Creates a mock hot observable sequence. The sequence will emit events at designated times,
        // no matter if there are observers subscribed or not (that's what hot means).
        // This observable sequence will also record all subscriptions made during its lifetime (`subscriptions` property).
        let consumablesMocked = scheduler.createHotObservable([
            .next(210, mintedToken(3)),
            .next(220, mintedToken(5)),
            .next(230, mintedToken(11)),
            .completed(500)
        ])
        
        // `start` method will by default:
        // * Run the simulation and record all events using observer referenced by `res`.
        // * Subscribe at virtual time 200
        // * Dispose subscription at virtual time 1000
        let result = scheduler.start { consumablesMocked.map { $0 } }
        
        let spunConsumables: [SpunConsumable] = result.events.compactMap { $0.value.element }
        let reducer = TokenBalanceReducer()
        let balances = reducer.reduce(spunConsumables: spunConsumables)

        guard let xrdBalance = balances[xrd] else { return XCTFail("Should not be nil") }
        XCTAssertEqual(xrdBalance.amount.signedAmount.magnitude, 19)
        XCTAssertLessThan(xrdBalance.amount.signedAmount.magnitude, 20)
        XCTAssertGreaterThan(xrdBalance.amount.signedAmount.magnitude, 18)
    }
}


private let address: Address = "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
private let xrd = TokenDefinitionReference(address: address, symbol: "XRD")

private extension TokenBalanceReducerTests {
    func mintedToken(_ amount: Amount, spin: Spin = .up) -> SpunConsumable {
        return SpunConsumable(
            spin: spin,
            any: MintedTokenParticle(
                address: address,
                amount: amount,
                tokenDefinitionReference: xrd
            )
        )
    }
    
    func transferredToken(_ amount: Amount, spin: Spin = .up) -> SpunConsumable {
        return SpunConsumable(
            spin: spin,
            any: TransferredTokenParticle(
                address: address,
                amount: amount,
                tokenDefinitionReference: xrd
            )
        )
    }
}
