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

class TransferTokensTests: LocalhostNodeTest {
    
    private var aliceIdentity: AbstractIdentity!
    private var bobAccount: Account!
    private var application: RadixApplicationClient!
    private var alice: Address!
    private var bob: Address!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        aliceIdentity = AbstractIdentity(alias: "Alice")
        bobAccount = Account()
        application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: aliceIdentity)
        alice = application.addressOfActiveAccount
        bob = application.addressOf(account: bobAccount)
    }
    

//    private lazy var alice: Address = {
//        return application.addressOfActiveAccount
//    }()
//
//    private lazy var bob: Address = {
//        return application.addressOf(account: bobAccount)
//    }()

    func testTransferTokenWithGranularityOf1() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
 
        // WHEN: Alice transfer tokens she owns, to Bob
        let createToken = createTokenAction(address: alice, supply: .fixed(to: 30))
        XCTAssertTrue(
            application.create(token: createToken).blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        let rri = createToken.identifier
        guard let myTokenDef = application.observeTokenDefinition(identifier: rri).blockingTakeFirst(timeout: 2) else { return }
        XCTAssertEqual(myTokenDef.symbol, "AC")
        
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: 10, tokenResourceIdentifier: rri))

        // THEN: I see that the transfer actions completes successfully
        XCTAssertTrue(
            transfer.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
    }
    
    func testTokenNotOwned() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob

        // WHEN: Alice tries to transfer tokens of some type she does not own, to Bob
        let amount: PositiveAmount = 10
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: amount, tokenResourceIdentifier: ResourceIdentifier(address: alice.address, name: "notOwned")))
        
        // THEN:  I see that action fails with error `InsufficientFunds`
        transfer.blockingAssertThrows(
            error: TransferError.insufficientFunds(currentBalance: .zero, butTriedToTransfer: amount)
        )
    }
    
    func testInsufficientFunds() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
      
        // WHEN: Alice tries to transfer tokens with a larger amount than her current balance, to Bob
        let initialSupply: Supply = 30
        let createToken = createTokenAction(address: alice, supply: .fixed(to: initialSupply))
        XCTAssertTrue(
            application.create(token: createToken).blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        let rri = createToken.identifier
        let amount: PositiveAmount = 50
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: amount, tokenResourceIdentifier: rri))
        
        // THEN:  I see that action fails with error `InsufficientFunds`
        transfer.blockingAssertThrows(
            error: TransferError.insufficientFunds(currentBalance: initialSupply.amount, butTriedToTransfer: amount)
        )
    }
    
    func testTransferTokenWithGranularityOf10() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
  
        // WHEN: Alice transfer tokens she owns, having a granularity larger than 1, to Bob
        let createToken = createTokenAction(address: alice, supply: .fixed(to: 10000), granularity: 10)
        
        XCTAssertTrue(
            application.create(token: createToken).blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        let rri = createToken.identifier
        
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: 20, tokenResourceIdentifier: rri))
        
        // THEN: I see that the transfer actions completes successfully
        XCTAssertTrue(
            transfer.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
    }
    
    func testIncorrectGranularityOf5() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        
        let granularity: Granularity = 5
        
        // WHEN: Alice tries to transfer an amount of tokens not being a multiple of the granularity of said token, to Bob
        let createToken = createTokenAction(address: alice, supply: .fixed(to: 10000), granularity: granularity)
        XCTAssertTrue(
            application.create(token: createToken).blockingWasSuccessfull(timeout: .enoughForPOW),
            "Failed to create token"
        )
        
        let amountToSend: PositiveAmount = 7
        
        let rri = createToken.identifier
        let transfer = application.transfer(tokens: TransferTokenAction(from: alice, to: bob, amount: amountToSend, tokenResourceIdentifier: rri))
        
        // THEN: I see that action fails with an error saying that the granularity of the amount did not match the one of the Token.
        transfer.blockingAssertThrows(
            error: TransferError.amountNotMultipleOfGranularity(amount: amountToSend, tokenGranularity: granularity),
            timeout: .enoughForPOW
        )
    }
    
}

private extension TransferTokensTests {
    func createTokenAction(address: Address, supply: CreateTokenAction.InitialSupply, granularity: Granularity = .default) -> CreateTokenAction {
        return try! CreateTokenAction(
            creator: address,
            name: "Alice Coin",
            symbol: "AC",
            description: "Best coin",
            supply: supply,
            granularity: granularity
        )
    }
}

private let magic: Magic = 63799298
