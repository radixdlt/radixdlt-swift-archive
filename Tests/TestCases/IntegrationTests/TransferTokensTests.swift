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

import XCTest
@testable import RadixSDK
import Combine

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
        
        aliceIdentity = AbstractIdentity()
        bobAccount = Account()
        carolAccount = Account()
        application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.default, identity: aliceIdentity)
        alice = application.addressOfActiveAccount
        bob = application.addressOf(account: bobAccount)
        carol = application.addressOf(account: carolAccount)
    }

    func testTransferTokenWithGranularityOf1() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        // WHEN: Alice transfer tokens she owns, to Bob
        let (tokenCreation, rri) = application.createToken(symbol: "AC", supply: .fixed(to: 30))
        
        let tokenCreationRecording = tokenCreation.completion.record()
        
        try wait(for: tokenCreationRecording.finished, timeout: .enoughForPOW)
        
        let myTokenDefRecording = application.observeTokenDefinition(identifier: rri).record()
        let myTokenDef = try wait(for: myTokenDefRecording.firstOrError, timeout: .enoughForPOW)
        
        XCTAssertEqual(myTokenDef.symbol, "AC")
        let myBalanceOrNilBeforeTxRecording = application.observeMyBalance(ofToken: rri).record()
        let myBalanceOrNilBeforeTx = try wait(for: myBalanceOrNilBeforeTxRecording.firstOrError, timeout: .enoughForPOW)
        
        let myBalanceBeforeTx = try XCTUnwrap(myBalanceOrNilBeforeTx)
        XCTAssertEqual(myBalanceBeforeTx.token.tokenDefinitionReference, rri)
        XCTAssertEqual(myBalanceBeforeTx.amount, 30)
        
        let attachedMessage = "For taxi fare"
        let transfer = application.transferTokens(identifier: rri, to: bob, amount: 10, message: attachedMessage)
        
        let transferRecording = transfer.completion.record()
        
        // THEN: I see that the transfer actions completes successfully
        try wait(for: transferRecording.finished, timeout: .enoughForPOW)

        let myBalanceOrNilAfterTxRecording = application.observeMyBalance(ofToken: rri).record()
        let myBalanceOrNilAfterTx = try wait(for: myBalanceOrNilAfterTxRecording.firstOrError, timeout: .enoughForPOW)
        
        let myBalanceAfterTx = try XCTUnwrap(myBalanceOrNilAfterTx)
        XCTAssertEqual(myBalanceAfterTx.amount, 20)
        
        let bobsBalanceOrNilAfterTxRecording = application.observeBalance(ofToken: rri, ownedBy: bob).record()
        let bobsBalanceOrNilAfterTx = try wait(for: bobsBalanceOrNilAfterTxRecording.firstOrError, timeout: .enoughForPOW)
        let bobsBalanceAfterTx = try XCTUnwrap(bobsBalanceOrNilAfterTx)
        XCTAssertEqual(bobsBalanceAfterTx.amount, 10)
        
        let myTransferRecording = application.observeMyTokenTransfers().record()
        let myTransfer = try wait(for: myTransferRecording.firstOrError, timeout: .enoughForPOW)
        XCTAssertEqual(myTransfer.sender, alice)
        XCTAssertEqual(myTransfer.recipient, bob)
        XCTAssertEqual(myTransfer.amount, 10)
        let decodedAttachedMessage = try XCTUnwrap(myTransfer.attachedMessage())
        XCTAssertEqual(decodedAttachedMessage, attachedMessage)
        
        let bobTransferRecording = application.observeTokenTransfers(toOrFrom: bob).record()
        let bobTransfer = try wait(for: bobTransferRecording.firstOrError, timeout: .enoughForPOW)
        XCTAssertEqual(bobTransfer.sender, alice)
        XCTAssertEqual(bobTransfer.recipient, bob)
        XCTAssertEqual(bobTransfer.amount, 10)
    }
    
    func testTokenNotOwned() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob

        // WHEN: Alice tries to transfer tokens of some type she does not own, to Bob
        let amount: PositiveAmount = 10
        let unknownRRI = ResourceIdentifier(address: alice.address, name: "Unknown")
        let transferAction = TransferTokensAction(from: alice, to: bob, amount: amount, tokenResourceIdentifier: unknownRRI)
        let transfer = application.transfer(tokens: transferAction)
        
        let recorder = transfer.completion.record()
        
        // THEN:  I see that action fails with error `foundNoTokenDefinition`
        let recordedThrownError: TransactionError = try wait(
            for: recorder.expectError(),
            timeout: .enoughForPOW,
            description: "Using unknown RRI should throw error"
        )
      
        XCTAssertEqual(
            recordedThrownError,
            .actionsToAtomError(
                .transferError(
                    .consumeError(.unknownToken(identifier: unknownRRI)),
                    action: transferAction
                )
            )
        )
    }
  
    func testInsufficientFunds() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
      
        // WHEN: Alice tries to transfer tokens with a larger amount than her current balance, to Bob
        let initialSupply: PositiveSupply = 30
        let (tokenCreation, rri) =  application.createFixedSupplyToken(supply: initialSupply)

        try wait(for: tokenCreation.completion.record().finished, timeout: .enoughForPOW)

        let amount: PositiveAmount = 50
        
        let transferTokensAction = TransferTokensAction(
            from: application.addressOfActiveAccount,
            to: bob,
            amount: amount,
            tokenResourceIdentifier: rri
        )
        
        let transfer = application.transfer(tokens: transferTokensAction)
        
        let transferRecording = transfer.completion.record()
        
        // THEN:  I see that action fails with error `InsufficientFunds`
        let recordedThrownError: TransactionError = try wait(
            for: transferRecording.expectError(),
            timeout: .enoughForPOW
        )
        
        XCTAssertEqual(
            recordedThrownError,
            .actionsToAtomError(
                .transferError(
                    .insufficientFunds(currentBalance: NonNegativeAmount(subset: initialSupply), butTriedToTransfer: amount),
                    action: transferTokensAction
                )
            )
        )
    }
    
    func testTransferTokenWithGranularityOf10() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
  
        // WHEN: Alice transfer tokens she owns, having a granularity larger than 1, to Bob
        let (tokenCreation, rri) = application.createFixedSupplyToken(supply: 10000, granularity: 10)
        try wait(for: tokenCreation.completion.record().finished, timeout: .enoughForPOW)
       
        // THEN: I see that the transfer actions completes successfully
        let transfer = application.transferTokens(identifier: rri, to: bob, amount: 20)
        try wait(for: transfer.completion.record().finished, timeout: .enoughForPOW)
    }
    
    func testIncorrectGranularityOf5() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        
        let (tokenCreation, rri) = application.createFixedSupplyToken(supply: 100, granularity: 5)
        try wait(for: tokenCreation.completion.record().finished, timeout: .enoughForPOW)
        
        // WHEN: Alice tries to transfer an amount of tokens not being a multiple of the granularity of said token, to Bob
        let transfer = application.transferTokens(identifier: rri, to: bob, amount: 7)
     
        // THEN: Transfer should fail
        try waitFor(
            transfer: transfer,
            toFailWithError: .consumeError(
                .amountNotMultipleOfGranularity(token: rri, triedToConsumeAmount: 7, whichIsNotMultipleOfGranularity: 5)
            ),
            because: "The amount 7 is not a multiple of granularity 5 (both are primes)"
        )
    }
    
    func testFailingTransferAliceTriesToSpendCarolsCoins() throws {
        
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        let (tokenCreation, rri) = application.createFixedSupplyToken(supply: 10000, granularity: 10)
        try wait(for: tokenCreation.completion.record().finished, timeout: .enoughForPOW)
        
        // WHEN: Alice tries to spend Carols coins
        let transfer = application.transfer(tokens: TransferTokensAction(from: carol, to: bob, amount: 20, tokenResourceIdentifier: rri))
        
        // THEN: Transfer should fail
        try waitFor(
            transfer: transfer,
            toFailWithError: .consumeError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: carol)),
            because: "Alice tries to spend Carols coins"
        )
    }
}

private extension TransferTokensTests {
    
    func waitFor(
        transfer: PendingTransaction,
        toFailWithError transferError: TransferError,
        because description: String,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws {
        
        let transferTokensAction: TransferTokensAction = try XCTUnwrap(transfer.firstAction(), line: line)
        let transferRecording = transfer.completion.record()
        
        let recordedThrownError: TransactionError = try wait(
            for: transferRecording.expectError(),
            timeout: timeout,
            description: description
        )
        
        XCTAssertEqual(
            recordedThrownError,
            TransactionError.actionsToAtomError(
                .transferError(
                    transferError,
                    action: transferTokensAction
                )
            ),
            line: line
        )
    }
}
