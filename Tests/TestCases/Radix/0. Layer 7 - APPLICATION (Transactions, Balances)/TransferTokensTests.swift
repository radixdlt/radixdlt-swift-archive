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

class TransferTokensTests: WebsocketTest {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testCreateTokenThenTransferToBob() {
        // GIVEN
        // Identities: Alice and Bob
        // and
        // an Application Layer using Alice identity
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        print("🙋🏾‍♀️ Alice: \(alice.address)")
        print("🙋🏼‍♂️ Bob: \(bob.address)")
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
        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: nil) else { return }
        XCTAssertEqual(rri.name, "AC")
        guard let alicesBalanceOfHerCoin = application.getMyBalance(of: rri).blockingTakeFirst() else { return }
        guard let bobsBalanceOfAliceCoin = application.getBalances(for: bob.address, ofToken: rri).blockingTakeFirst() else { return }
        
        // THEN
        XCTAssertEqual(
            alicesBalanceOfHerCoin.balance.amount,
            30,
            "Alice's balance should equal `30` (initialSupply)"
        )
        XCTAssertEqual(
            bobsBalanceOfAliceCoin.balance.amount,
            0,
            "Bob's balance should equal 0"
        )
        
        // AND WHEN
        // Alice sends 10 coins to Bob
        let txAmount: PositiveAmount = 10
        let transfer = TransferTokenAction(from: alice, to: bob, amount: txAmount, tokenResourceIdentifier: rri)

        XCTAssertTrue(
            application.transfer(tokens: transfer).take(1)
                .toBlocking(timeout: nil)
                .materialize()
                .wasSuccessful
            ,
            "Should be able to send coins to Bob"
        )
     
        print("💸: 🙋🏾‍♀️→ \(txAmount)💰 →🙋🏼‍♂️")

        // ...and we update the balances
        guard let alicesBalanceOfHerCoinAfterTx = application.getMyBalance(of: rri).blockingTakeLast() else { return }
        guard let bobsBalanceOfAliceCoinAfterTx = application.getBalances(for: bob.address, ofToken: rri).blockingTakeLast() else { return }

        // THEN
        XCTAssertEqual(
            alicesBalanceOfHerCoinAfterTx.balance.amount,
            20,
            "Alice's balance should equal `20`"
        )
        
        XCTAssertEqual(
            bobsBalanceOfAliceCoinAfterTx.balance.amount,
            10,
            "Bob's balance should equal 10"
        )
        
        
    }
    
}

private let magic: Magic = 63799298

private extension RadixIdentity {
    init() {
        self.init(magic: magic)
    }
}
