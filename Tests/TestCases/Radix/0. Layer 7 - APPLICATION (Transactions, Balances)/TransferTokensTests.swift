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

    func testTransferTokenWithGranularityOf1() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
 
        // WHEN: Alice transfer tokens she owns, to Bob
        let createToken = createTokenAction(identity: alice, supply: .fixed(to: 30))
        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: RxTimeInterval.enoughForPOW) else { return }
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: 10, tokenResourceIdentifier: rri))

        // THEN: I see that the transfer actions completes successfully
        XCTAssertTrue(
            transfer.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW)
        )
    }
    
    func testTokenNotOwned() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
        
        // WHEN: Alice tries to transfer tokens of some type she does not own, to Bob
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: 10, tokenResourceIdentifier: ResourceIdentifier(address: alice.address, name: "notOwned")))
        
        // THEN:  I see that action fails with error `InsufficientFunds`
        transfer.blockingAssertThrows(
            error: TransferError.insufficientFunds
        )
    }
    
    func testInsufficientFunds() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
        
        // WHEN: Alice tries to transfer tokens with a larger amount than her current balance, to Bob
        let createToken = createTokenAction(identity: alice, supply: .fixed(to: 30))
        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: RxTimeInterval.enoughForPOW) else { return }
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: 50, tokenResourceIdentifier: rri))
        
        // THEN:  I see that action fails with error `InsufficientFunds`
        transfer.blockingAssertThrows(
            error: TransferError.insufficientFunds
        )
    }
    
    func testTransferTokenWithGranularityOf10() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
        
        // WHEN: Alice transfer tokens she owns, having a granularity larger than 1, to Bob
        let createToken = createTokenAction(identity: alice, supply: .fixed(to: 10000), granularity: 10)
        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: RxTimeInterval.enoughForPOW) else { return }
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: 20, tokenResourceIdentifier: rri))
        
        // THEN: I see that the transfer actions completes successfully
        XCTAssertTrue(
            transfer.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW)
        )
    }
    
    func testIncorrectGranularityOf5() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
        
        // WHEN: Alice tries to transfer an amount of tokens not being a multiple of the granularity of said token, to Bob
        let createToken = createTokenAction(identity: alice, supply: .fixed(to: 10000), granularity: 5)
        guard let rri = application.create(token: createToken).blockingTakeFirst(timeout: RxTimeInterval.enoughForPOW) else { return }
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: 7, tokenResourceIdentifier: rri))
        
        // THEN: I see that action fails with an error saying that the granularity of the amount did not match the one of the Token.
        transfer.blockingAssertThrows(
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
