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

class TransactionsTests: IntegrationTest {
    
    func testTransactionWithSingleCreateTokenActionWithoutInitialSupply() throws {
        // GIVEN identity alice and a RadixApplicationClient
        
        // WHEN Alice observes her transactions after creating token without
        let (tokenCreation, _) = application.createToken(supply: .mutableZeroSupply)
        
        try waitForTransactionToFinish(tokenCreation)
        
        // THEN said single CreateTokenAction can be seen in the transaction
        let transaction = try waitForFirstValue(of: application.observeMyTransactions())
        XCTAssertEqual(transaction.actions.count, 1)
        
        guard let createTokenAction = transaction.actions.first as? CreateTokenAction else {
            return XCTFail("Transaction is expected to contain exactly one `CreateTokenAction`, nothing else.")
        }
        XCTAssertEqual(createTokenAction.tokenSupplyType, .mutable)
    }
    
    func testTransactionWithSingleCreateTokenActionWithInitialSupply() throws {
        // GIVEN identity alice and a RadixApplicationClient
        
        // WHEN Alice observes her transactions after having made one with a single `CreateTokenAction`
        let (tokenCreation, _) = application.createToken(supply: .mutable(initial: 123))
        
        try waitForTransactionToFinish(tokenCreation)
        
        let transaction = try waitForFirstValue(of: application.observeMyTransactions())
        
        switch transaction.actions.countedElementsZeroOneTwoAndMany {
        // THEN one CreateTokenAction can be seen in the transaction
        case .two(let first, let secondAndLast):
            guard
                let createTokenAction = first as? CreateTokenAction,
                let mintTokenAction = secondAndLast as? MintTokensAction
            else { return XCTFail("Expected first action to be `CreateTokenAction`, and second to be MintTokensAction.")  }
            
            XCTAssertEqual(createTokenAction.tokenSupplyType, .mutable)
            XCTAssertEqual(mintTokenAction.amount, 123)
        default: XCTFail("Expected exactly two actions")
        }

    }
    
    func testTransactionWithSingleTransferTokensAction() throws {
        // GIVEN identity alice and a RadixApplicationClient
        // GIVEN: and bob
        // GIVEN: and `FooToken` created by Alice
        let (tokenCreation, fooToken) =
            application.createToken(supply: .mutable(initial: 10))
        
        try waitForTransactionToFinish(tokenCreation)
        
        let transfer = application.transferTokens(
            identifier: fooToken,
            to: bob,
            amount: 5,
            message: "For taxi fare"
        )
        
        try waitForTransactionToFinish(transfer)
        
        // WHEN: and observes her transactions
        let transaction = try waitForFirstValue(of: application.observeMyTransactions(containingActionOfType: TransferTokensAction.self))
        
        // THEN she sees a Transaction containing just the TransferTokensAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let transferTokensAction = transaction.actions.first as? TransferTokensAction else {
            return XCTFail("Transaction is expected to contain exactly one `BurnTokensAction`, nothing else.")
        }
        XCTAssertEqual(transferTokensAction.amount, 5)
        XCTAssertEqual(transferTokensAction.recipient, bob)
        XCTAssertEqual(transferTokensAction.attachedMessage(), "For taxi fare")
        XCTAssertEqual(transferTokensAction.sender, alice)
    }
    
    func testTransactionWithSingleBurnTokensAction() throws {
        // GIVEN identity alice and a RadixApplicationClient

        // GIVEN: and `FooToken` created by Alice
        
        let (tokenCreation, fooToken) =
            application.createToken(supply: .mutable(initial: 123))
        
        try waitForTransactionToFinish(tokenCreation)
        
        let burning = application.burnTokens(amount: 23, ofType: fooToken)
        try waitForTransactionToFinish(burning)
        
        // WHEN: and observes her transactions
        let transaction = try waitForFirstValue(of: application.observeMyTransactions(containingActionOfType: BurnTokensAction.self))
        
        // THEN she sees a Transaction containing just the BurnTokensAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let burnTokensAction = transaction.actions.first as? BurnTokensAction else {
            return XCTFail("Transaction is expected to contain exactly one `BurnTokensAction`, nothing else.")
        }
        XCTAssertEqual(burnTokensAction.amount, 23)
    }
    
    func testTransactionWithSingleMintTokensAction() throws {
        // GIVEN identity alice and a RadixApplicationClient
        
        // GIVEN: and `FooToken` created by Alice
        
        let (tokenCreation, fooToken) =
            application.createToken(supply: .mutableZeroSupply)
        
        try waitForTransactionToFinish(tokenCreation)
        
        //  WHEN: Alice makes a transaction containing a single MintTokensAction of FooToken
        let minting = application.mintTokens(amount: 23, ofType: fooToken)
        try waitForTransactionToFinish(minting)
        
        // WHEN: and observes her transactions
        let transaction = try waitForFirstValue(of: application.observeMyTransactions(containingActionOfType: MintTokensAction.self))
        
        // THEN she sees a Transaction containing just the MintTokensAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let mintTokensAction = transaction.actions.first as? MintTokensAction else {
            return XCTFail("Transaction is expected to contain exactly one `MintTokensAction`, nothing else.")
        }
        XCTAssertEqual(mintTokensAction.amount, 23)
    }
    
    func testTransactionWithSingleSendMessageAction() throws {
        // GIVEN identity alice and a RadixApplicationClient
        
        // WHEN Alice observes her transactions after having made one with a single `SendMessageAction`
        let messageSending = application.sendEncryptedMessage("Hey Bob, this is secret!", to: bob)
        try waitForTransactionToFinish(messageSending)
        
        // WHEN: and observes her transactions
        let transaction = try waitForFirstValue(of: application.observeMyTransactions())
        
        // THEN she sees a Transaction containing the SendMessageAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let sendMessageAction = transaction.actions.first as? SendMessageAction else {
            return XCTFail("Transaction is expected to contain exactly one `SendMessageAction`, nothing else.")
        }
        XCTAssertEqual(sendMessageAction.sender, alice)
        XCTAssertEqual(sendMessageAction.recipient, bob)
        XCTAssertEqual(sendMessageAction.decryptionContext, .decrypted)
        XCTAssertEqual(sendMessageAction.textMessage(), "Hey Bob, this is secret!")
    }
    
    /*
    func testTransactionWithSinglePutUniqueAction() {
        // GIVEN identity alice and a RadixApplicationClient
        
        // WHEN Alice observes her transactions after having made one with a single `PutUniqueIdAction`
        XCTAssertTrue(
            application.putUnique(string: "Foobar")
                .blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        // WHEN: and observes her transactions
        guard let transaction = application.observeMyTransactions().blockingTakeFirst() else {
            return
        }

        // THEN she sees a Transaction containing the SendMessageAction
        XCTAssertEqual(transaction.actions.count, 1)
        guard let putUniqueAction = transaction.actions.first as? PutUniqueIdAction else {
            return XCTFail("Transaction is expected to contain exactly one `PutUniqueIdAction`, nothing else.")
        }
        XCTAssertEqual(putUniqueAction.uniqueMaker, alice)
        XCTAssertEqual(putUniqueAction.string, "Foobar")
    }
    
    func testTransactionWithTwoMintTokenAndTwoPutUniqueIdActions() {
        // GIVEN identity alice and a RadixApplicationClient
        
        // GIVEN: and `FooToken` created by Alice
        
        let (tokenCreation, fooToken) =
            application.createToken(supply: .mutableZeroSupply)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        //  WHEN: Alice makes a transaction containing 2 MintTokensAction of FooToken and 2 PutUnique and observes her transactions
        let newTransaction = Transaction { // using Swift 5.1's function builder
            MintTokensAction(tokenDefinitionReference: fooToken, amount: 5, minter: alice)
            MintTokensAction(tokenDefinitionReference: fooToken, amount: 10, minter: alice)
            PutUniqueIdAction(uniqueMaker: alice, string: "Mint5")
            PutUniqueIdAction(uniqueMaker: alice, string: "Mint10")
        }
            
        XCTAssertTrue(
            application.make(transaction: newTransaction)
                .blockingWasSuccessful(timeout: 40)
        )
        
        // WHEN: and observes her transactions
        guard let transaction = application.observeMyTransactions(containingActionsOfAllTypes: [PutUniqueIdAction.self, MintTokensAction.self])
            .blockingTakeFirst() else { return }
        
        // THEN she sees a Transaction containing the 2 MintTokensAction and 2 PutUniqueActions
        XCTAssertEqual(transaction.actions.count, 4)
        guard
            let mint5 = transaction.actions[0] as? MintTokensAction,
            let mint10 = transaction.actions[1] as? MintTokensAction,
            let unique5 = transaction.actions[2] as? PutUniqueIdAction,
            let unique10 = transaction.actions[3] as? PutUniqueIdAction
            else { return XCTFail("Wrong actions") }
        
        XCTAssertEqual(unique5.string, "Mint5")
        XCTAssertEqual(unique10.string, "Mint10")
        XCTAssertEqual(mint5.amount, 5)
        XCTAssertEqual(mint10.amount, 10)
    }
    
    func testTransactionWithNoActions() {
        let someParticle = ResourceIdentifierParticle(
            resourceIdentifier: ResourceIdentifier(address: alice, name: "WHATEVER")
        )
        
        let atom = Atom(particle: someParticle)
        
        let atomToTransactionMapper = DefaultAtomToTransactionMapper(identity: aliceIdentity)
        guard let transaction = atomToTransactionMapper.transactionFromAtom(atom).blockingTakeFirst() else { return }
        XCTAssertEqual(transaction.actions.count, 0)
        XCTAssertGreaterThanOrEqual(transaction.sentAt.timeIntervalSinceNow, -0.01) // max 10 ms ago
    }
    
    private let bag = DisposeBag()
    func testTransactionComplex() {
        let (tokenCreation, fooToken) = application.createToken(supply: .mutable(initial: 35))
                
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        let mintAndUniqueTx = Transaction {
            MintTokensAction(tokenDefinitionReference: fooToken, amount: 5, minter: alice)
            PutUniqueIdAction(uniqueMaker: alice, string: "mint")
        }
        
        XCTAssertTrue(
            application.make(transaction: mintAndUniqueTx)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        let burnAndUniqueTx = Transaction {
            BurnTokensAction(tokenDefinitionReference: fooToken, amount: 5, burner: alice)
            PutUniqueIdAction(uniqueMaker: alice, string: "burn")
        }
        
        XCTAssertTrue(
            application.make(transaction: burnAndUniqueTx)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        let onlyUniqueTx = Transaction {
            PutUniqueIdAction(uniqueMaker: alice, string: "unique")
        }
        
        XCTAssertTrue(
            application.make(transaction: onlyUniqueTx)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        
        guard let putUniqueTransactions = application.observeMyTransactions(containingActionOfAnyType: [PutUniqueIdAction.self]).blockingArrayTakeFirst(3) else { return }
        XCTAssertEqual(
            putUniqueTransactions.flatMap { $0.actions(ofType: PutUniqueIdAction.self) }.map { $0.string }.sorted(),
            ["burn", "mint", "unique"]
        )
        
        guard let burnTxs = application.observeMyTransactions(containingActionOfAnyType: [BurnTokensAction.self]).blockingArrayTakeFirst(1) else { return }
        XCTAssertEqual(burnTxs.count, 1)
        XCTAssertEqual(burnTxs[0].actions.count, 2)
        
        guard let burnOrMintTransactions = application.observeMyTransactions(containingActionOfAnyType: [BurnTokensAction.self, MintTokensAction.self]).blockingArrayTakeFirst(2) else { return }
        
        XCTAssertEqual(burnOrMintTransactions.count, 2)
        
        guard let uniqueBurnTransactions = application.observeMyTransactions(containingActionsOfAllTypes: [PutUniqueIdAction.self, BurnTokensAction.self]).blockingTakeFirst() else { return }
        
        guard case let uniqueActionInBurnTxs = uniqueBurnTransactions.actions(ofType: PutUniqueIdAction.self), let uniqueActionInBurnTx = uniqueActionInBurnTxs.first else { return XCTFail("Expected UniqueAction") }
        XCTAssertEqual(uniqueActionInBurnTx.string, "burn")
        
        guard let uniqueMintTransactions = application.observeMyTransactions(containingActionsOfAllTypes: [PutUniqueIdAction.self, MintTokensAction.self]).blockingTakeFirst() else { return }
        
        guard case let uniqueActionInMintTxs = uniqueMintTransactions.actions(ofType: PutUniqueIdAction.self), let uniqueActionInMintTx = uniqueActionInMintTxs.first else { return XCTFail("Expected UniqueAction") }
        XCTAssertEqual(uniqueActionInMintTx.string, "mint")
    }
 */
}
