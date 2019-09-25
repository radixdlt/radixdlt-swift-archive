//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    private var carolAccount: Account!
    private var carol: Address!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        aliceIdentity = AbstractIdentity()
        bobAccount = Account()
        carolAccount = Account()
        application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.default, identity: aliceIdentity)
        alice = application.addressOfActiveAccount
        bob = application.addressOf(account: bobAccount)
        carol = application.addressOf(account: carolAccount)
    }
    
    func testTransferTokenWithGranularityOf1() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        // WHEN: Alice transfer tokens she owns, to Bob
        let (tokenCreation, rri) = application.createToken(symbol: "AC", supply: .fixed(to: 30))
        
        // createTokenAction(address: alice, supply: .fixed(to: 30))
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        guard let myTokenDef = application.observeTokenDefinition(identifier: rri).blockingTakeFirst() else { return }
        XCTAssertEqual(myTokenDef.symbol, "AC")
        
        guard let myBalanceOrNilBeforeTx = application.observeMyBalance(ofToken: rri).blockingTakeFirst() else { return }
        guard let myBalanceBeforeTx = myBalanceOrNilBeforeTx else { return XCTFail("Expected non nil balance") }
        XCTAssertEqual(myBalanceBeforeTx.token.tokenDefinitionReference, rri)
        XCTAssertEqual(myBalanceBeforeTx.amount, 30)
        
        let attachedMessage = "For taxi fare"
        let transfer = application.transferTokens(identifier: rri, to: bob, amount: 10, message: attachedMessage)
        
        // THEN: I see that the transfer actions completes successfully
        XCTAssertTrue(
            transfer.blockingWasSuccessful(timeout: .enoughForPOW)
        )

        guard let myBalanceOrNilAfterTx = application.observeMyBalance(ofToken: rri).blockingTakeLast() else { return }
        guard let myBalanceAfterTx = myBalanceOrNilAfterTx else { return XCTFail("Expected non nil balance") }
        XCTAssertEqual(myBalanceAfterTx.amount, 20)
        
        guard let bobsBalanceOrNilAfterTx = application.observeBalance(ofToken: rri, ownedBy: bob).blockingTakeFirst() else { return }
        guard let bobsBalanceAfterTx = bobsBalanceOrNilAfterTx else { return XCTFail("Expected non nil balance") }
        XCTAssertEqual(bobsBalanceAfterTx.amount, 10)
        
        guard let myTransfer = application.observeMyTokenTransfers().blockingTakeFirst() else { return }
        XCTAssertEqual(myTransfer.sender, alice)
        XCTAssertEqual(myTransfer.recipient, bob)
        XCTAssertEqual(myTransfer.amount, 10)
        guard let decodedAttachedMessage = myTransfer.attachedMessage() else { return XCTFail("Expected attachment") }
        XCTAssertEqual(decodedAttachedMessage, attachedMessage)
        
        guard let bobTransfer = application.observeTokenTransfers(toOrFrom: bob).blockingTakeFirst() else { return }
        XCTAssertEqual(bobTransfer.sender, alice)
        XCTAssertEqual(bobTransfer.recipient, bob)
        XCTAssertEqual(bobTransfer.amount, 10)
    }
    
    func testTokenNotOwned() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob

        // WHEN: Alice tries to transfer tokens of some type she does not own, to Bob
        let amount: PositiveAmount = 10
        let unknownRRI = ResourceIdentifier(address: alice.address, name: "Unknown")
        let transfer = application.transfer(tokens: TransferTokensAction(from: alice, to: bob, amount: amount, tokenResourceIdentifier: unknownRRI))
        
        // THEN:  I see that action fails with error `foundNoTokenDefinition`
        transfer.blockingAssertThrows(
            error: TransferError.consumeError(.unknownToken(identifier: unknownRRI))
        )
    }
    
    func testInsufficientFunds() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
      
        // WHEN: Alice tries to transfer tokens with a larger amount than her current balance, to Bob
        let initialSupply: PositiveSupply = 30
        let (tokenCreation, rri) =  application.createFixedSupplyToken(supply: initialSupply)

        XCTAssertTrue(
           tokenCreation.blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        let amount: PositiveAmount = 50
        let transfer = application.transferTokens(identifier: rri, to: bob, amount: amount)
        
        // THEN:  I see that action fails with error `InsufficientFunds`
        transfer.blockingAssertThrows(
            error: TransferError.insufficientFunds(currentBalance: NonNegativeAmount(positive: initialSupply.amount), butTriedToTransfer: amount)
        )
    }
    
    func testTransferTokenWithGranularityOf10() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
  
        // WHEN: Alice transfer tokens she owns, having a granularity larger than 1, to Bob
        let (tokenCreation, rri) = application.createFixedSupplyToken(supply: 10000, granularity: 10)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        let transfer = application.transferTokens(identifier: rri, to: bob, amount: 20)
        
        // THEN: I see that the transfer actions completes successfully
        XCTAssertTrue(
            transfer.blockingWasSuccessful(timeout: .enoughForPOW)
        )
    }
    
    func testIncorrectGranularityOf5() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        
        let granularity: Granularity = 5
        
        // WHEN: Alice tries to transfer an amount of tokens not being a multiple of the granularity of said token, to Bob
        let (tokenCreation, rri) = application.createFixedSupplyToken(supply: 100, granularity: granularity)

        XCTAssertTrue(
            tokenCreation.blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        let amountToSend: PositiveAmount = 7
        
        let transfer = application.transferTokens(identifier: rri, to: bob, amount: amountToSend)
        
        // THEN: I see that action fails with an error saying that the granularity of the amount did not match the one of the Token.
        transfer.blockingAssertThrows(
            error: TransferError.consumeError(
                .amountNotMultipleOfGranularity(
                    token: rri,
                    triedToConsumeAmount: amountToSend,
                    whichIsNotMultipleOfGranularity: granularity
                )
            ),
            timeout: .enoughForPOW
        )
    }
    
    func testFailingTransferAliceTriesToSpendCarolsCoins() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        
        let (tokenCreation, rri) = application.createFixedSupplyToken(supply: 10000, granularity: 10)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        // WHEN: Alice tries to spend Carols coins
        let transfer = application.transfer(tokens: TransferTokensAction(from: carol, to: bob, amount: 20, tokenResourceIdentifier: rri))
        
        // THEN: I see that it fails
        transfer.blockingAssertThrows(
            error: TransferError.consumeError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: carol))
        )
    }
    
}
