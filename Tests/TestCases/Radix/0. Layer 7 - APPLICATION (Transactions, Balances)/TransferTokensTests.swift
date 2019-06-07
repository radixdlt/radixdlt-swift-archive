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

    // AC1
    func testTransferTokenWithGranularityOf1() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
 
        let createToken = createTokenAction(identity: alice, supply: .fixed(to: 30))
        
        XCTAssertEqual(createToken.granularity, 1)

        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: RxTimeInterval.enoughForPOW) else { return }
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
        
        // WHEN: Alice transfer tokens she owns, to Bob
        let txAmount: PositiveAmount = 10
        let transfer = TransferTokenAction(from: alice, to: bob, amount: txAmount, tokenResourceIdentifier: rri)
        
        let request = application.transfer(tokens: transfer)

        // THEN: I see that the transfer actions completes successfully
        XCTAssertTrue(
            request.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW),
            "Should be able to send coins to Bob"
        )

        guard let alicesBalanceOfHerCoinAfterTx = application.getMyBalance(of: rri).blockingTakeLast() else { return }
        guard let bobsBalanceOfAliceCoinAfterTx = application.getBalances(for: bob.address, ofToken: rri).blockingTakeLast() else { return }

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
    
    // AC2
    func testTokenNotOwned() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
        
        // WHEN: Alice tries to transfer tokens of some type she does not own, to Bob
        let transfer = TransferTokenAction(from: alice, to: bob, amount: 10, tokenResourceIdentifier: ResourceIdentifier(address: alice.address, name: "notOwned"))
        
        // THEN:  I see that action fails with error `InsufficientFunds`
        application.transfer(tokens: transfer).blockingAssertThrows(
            error: TransferError.insufficientFunds
        )
    }
    
    // AC3
    func testInsufficientFunds() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
        
        let createToken = createTokenAction(identity: alice, supply: .fixed(to: 30))
        
        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: RxTimeInterval.enoughForPOW) else { return }
        XCTAssertEqual(rri.name, "AC")
        guard let alicesBalanceOfHerCoin = application.getMyBalance(of: rri).blockingTakeFirst() else { return }
        
        XCTAssertEqual(
            alicesBalanceOfHerCoin.balance.amount,
            30,
            "Alice's balance should equal `30` (initialSupply)"
        )
        
        // WHEN: Alice tries to transfer tokens of some type she does not own, to Bob
        let transfer = TransferTokenAction(from: alice, to: bob, amount: 50, tokenResourceIdentifier: rri)
        
        // THEN:  I see that action fails with error `InsufficientFunds`
        application.transfer(tokens: transfer).blockingAssertThrows(
            error: TransferError.insufficientFunds
        )
    }
    
    // AC 4
    func testTransferTokenWithGranularityOf5() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
        
        let createToken = createTokenAction(identity: alice, supply: .fixed(to: 30), granularity: 5)
        
        XCTAssertEqual(createToken.granularity, 5)
        
        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: RxTimeInterval.enoughForPOW) else { return }
        XCTAssertEqual(rri.name, "AC")
        guard let alicesBalanceOfHerCoin = application.getMyBalance(of: rri).blockingTakeFirst() else { return }
        guard let bobsBalanceOfAliceCoin = application.getBalances(for: bob.address, ofToken: rri).blockingTakeFirst() else { return }
        
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
        
        // WHEN: Alice transfer 20 (granularity of 10) tokens she owns, to Bob
        let txAmount: PositiveAmount = 10
        let transfer = TransferTokenAction(from: alice, to: bob, amount: txAmount, tokenResourceIdentifier: rri)
        
        let request = application.transfer(tokens: transfer)
        
        // THEN:  I see that the transfer actions completes successfully
        XCTAssertTrue(
            request.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW),
            "Should be able to send coins to Bob"
        )
        
        guard let alicesBalanceOfHerCoinAfterTx = application.getMyBalance(of: rri).blockingTakeLast() else { return }
        guard let bobsBalanceOfAliceCoinAfterTx = application.getBalances(for: bob.address, ofToken: rri).blockingTakeLast() else { return }
        
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
    
    // AC5
    func testIncorrectGranularityOf5() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
        
        let createToken = createTokenAction(identity: alice, supply: .fixed(to: 30), granularity: 5)
        
        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: RxTimeInterval.enoughForPOW) else { return }
        XCTAssertEqual(rri.name, "AC")
        guard let alicesBalanceOfHerCoin = application.getMyBalance(of: rri).blockingTakeFirst() else { return }
        
        XCTAssertEqual(
            alicesBalanceOfHerCoin.balance.amount,
            30,
            "Alice's balance should equal `30` (initialSupply)"
        )
        
        guard let bobsBalanceOfAliceCoin = application.getBalances(for: bob.address, ofToken: rri).blockingTakeLast() else { return }
        
        XCTAssertEqual(
            bobsBalanceOfAliceCoin.balance.amount,
            0,
            "Bob's balance should be 0"
        )
        
        // AND WHEN: Alice tries to transfer 7 tokens having granularity 5, to Bob
        let transfer = TransferTokenAction(from: alice, to: bob, amount: 7, tokenResourceIdentifier: rri)
        let request = application.transfer(tokens: transfer)
        
        // THEN:   I see that action fails with an error saying that the granularity of the amount did not match the one of the Token.
        request.blockingAssertThrows(
            error: TransferError.amountNotMultipleOfGranularity,
            timeout: RxTimeInterval.enoughForPOW
        )
    }
    
}

private extension TransferTokensTests {
    func createTokenAction(identity: RadixIdentity, supply: CreateTokenAction.InitialSupply, granularity: Granularity = .default) -> CreateTokenAction {
        return try! CreateTokenAction(
            creator: identity.address,
            name: "Alice Coin",
            symbol: "AC",
            description: "Best coin",
            supply: supply,
            granularity: granularity
        )
    }
}

private let magic: Magic = 63799298

private extension RadixIdentity {
    init() {
        self.init(magic: magic)
    }
}
