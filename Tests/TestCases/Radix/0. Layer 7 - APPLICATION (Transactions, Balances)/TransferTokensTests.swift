//
//  TransferTokensTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

import XCTest
@testable import RadixSDK
import RxSwift

private let magic: Magic = 63799298

private extension RadixIdentity {
    init() {
        self.init(magic: magic)
    }
}

class TransferTokensTests: XCTestCase {
    
    func testCreateTokenThenTransferToBob() {
        // GIVEN
        // Identities: Alice and Bob
        // and
        // an Application Layer using Alice identity
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
 
        let createToken = CreateTokenAction(
            creator: alice.address,
            name: "Alice Coin",
            symbol: "AC",
            description: "Best coin",
            supplyType: .fixed,
            initialSupply: 30
        )

        // WHEN
        // Alice creates a new token with an initial supply of 30
        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: RxTimeInterval.enoughForPOW) else { return }
        XCTAssertEqual(rri.name, "AC")
        guard let alicesBalanceOfHerCoin = application.getMyBalance(of: rri).blockingTakeFirst() else { return }
        guard let bobsBalanceOfAliceCoin = application.getBalances(for: bob.address, ofToken: rri).blockingTakeFirst() else { return }
        
        // THEN
        XCTAssertEqual(
            alicesBalanceOfHerCoin.amount,
            30,
            "Alice's balance should equal `30` (initialSupply)"
        )
        XCTAssertEqual(
            bobsBalanceOfAliceCoin.amount,
            0,
            "Bob's balance should equal 0"
        )
        
//        // AND WHEN
//        // Alice sends 10 coins to Bob
//        let transfer = TransferTokenAction(from: alice, to: bob, amount: 10, tokenResourceIdentifier: rri)
//        switch application.transfer(tokens: transfer).toBlocking(timeout: 2).materialize() {
//        case .completed: break // great!
//        case .failed(_, let error): XCTFail("Transfer failed - error: \(error)")
//        }
//
//        // ...and we update the balances
//        guard let alicesBalanceOfHerCoinAfterTx = application.getMyBalance(of: rri).blockingTakeLast() else { return }
//        guard let bobsBalanceOfAliceCoinAfterTx = application.getBalances(for: bob.address, ofToken: rri).blockingTakeLast() else { return }
//
//        // THEN
//        XCTAssertEqual(
//            alicesBalanceOfHerCoinAfterTx.amount,
//            20,
//            "Alice's balance should equal `20`"
//        )
//        XCTAssertEqual(
//            bobsBalanceOfAliceCoinAfterTx.amount,
//            10,
//            "Bob's balance should equal 10"
//        )
    }
    
}
