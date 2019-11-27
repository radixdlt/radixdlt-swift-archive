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
import Combine

class PutUniqueIdActionTests: LocalhostNodeTest {
    
    private var aliceIdentity: AbstractIdentity!
    private var bobAccount: Account!
    private var application: RadixApplicationClient!
    private var alice: Address!
    private var bob: Address!
    
    override func setUp() {
        super.setUp()
        
        aliceIdentity = AbstractIdentity()
        bobAccount = Account()
        application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.default, identity: aliceIdentity)
        alice = application.addressOfActiveAccount
        bob = application.addressOf(account: bobAccount)
    }

    func testSendTransactionWithSingleUniqueId() throws {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node

        // WHEN: Alice sends a `Transaction` containing a `UniqueId` with the string `"foobar"`
        let transaction = Transaction {
            PutUniqueIdAction(uniqueMaker: alice, string: "foobar")
        }
        let resultOfPutUniqueAction = application.send(transaction: transaction)
        
        let recorderCompletable = resultOfPutUniqueAction.completion.record()
        
        try wait(for: recorderCompletable.finished, timeout: .enoughForPOW)
        
        let executedTransactionsPublisher = application.observeTransactions(
            at: alice,
            containingActionOfAnyType: [PutUniqueIdAction.self]
        )
        
        let recorderTransactions = executedTransactionsPublisher.record()
        
        let executedTransaction: ExecutedTransaction = try wait(for: recorderTransactions.firstOrError, timeout: 1, description: "ExecutedTransactions")

        let putUniqueActions = executedTransaction.actions(ofType: PutUniqueIdAction.self)

        XCTAssertEqual(putUniqueActions.count, 1)
        let putUniqueAction = putUniqueActions[0]

        // THEN: AND we can read out the `UniqueId` string `"foobar"`
        XCTAssertEqual(putUniqueAction.string, "foobar")
    }
    
    func testSendTransactionWithTwoUniqueIds() throws {

        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node

        // WHEN: Alice sends a `Transaction` containing two UniqueId with the string "foo" and "bar” respectively
        let transaction = Transaction {
            PutUniqueIdAction(uniqueMaker: alice, string: "foo")
            PutUniqueIdAction(uniqueMaker: alice, string: "bar")
        }
        
        let resultOfPutUniqueActions = application.send(transaction: transaction)
        let recorderCompletable = resultOfPutUniqueActions.completion.record()
        try wait(for: recorderCompletable.finished, timeout: .enoughForPOW)
        
        let executedTransactionsPublisher = application.observeTransactions(
            at: alice,
            containingActionOfAnyType: [PutUniqueIdAction.self]
        )
        
        let recorderTransactions = executedTransactionsPublisher.record()
        
        let executedTransaction: ExecutedTransaction = try wait(for: recorderTransactions.firstOrError, timeout: 1, description: "ExecutedTransactions")
        
        let putUniqueActions = executedTransaction.actions(ofType: PutUniqueIdAction.self)

        XCTAssertEqual(putUniqueActions.count, 2)

        // THEN: AND we can read out the UniqueId strings "foo" and "bar”.
        XCTAssertEqual(putUniqueActions[0].string, "foo")
        XCTAssertEqual(putUniqueActions[1].string, "bar")
    }

    func testFailPuttingTwoEqualUniqueIdInOneTransaction() throws {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node

        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: alice, string: "foo")
        
        // WHEN: Alice sends a `Transaction` containing two UniqueId with with the same string
        let transaction = Transaction {
            putUniqueIdAction
            putUniqueIdAction
        }

        let resultOfPutUniqueActions = application.send(transaction: transaction)
        
        let recorderCompletable = resultOfPutUniqueActions.completion.record()
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        let putUniqueIdError = PutUniqueIdError.uniqueError(.rriAlreadyUsedByUniqueId(string: "foo"))
        
        let recordedThrownError: TransactionError = try wait(
            for: recorderCompletable.expectError(),
            timeout: .enoughForPOW,
            description: "Transaction containing two identical 'PutUniqueIdAction' should throw error"
        )
        
        let expectedError =  TransactionError.actionsToAtomError(
            ActionsToAtomError.putUniqueIdError(putUniqueIdError, action: putUniqueIdAction)
        )
        
        XCTAssertEqual(recordedThrownError, expectedError)
    }
    
    
    func testFailPuttingAnUniqueIdUsedInAPreviousTransaction() throws {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        
        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: alice, string: "foo")

        let resultOfPutUniqueAction = application.putUniqueId(putUniqueIdAction)
        
        let recorderCompletable = resultOfPutUniqueAction.completion.record()
         try wait(for: recorderCompletable.finished, timeout: .enoughForPOW)
       
        
        // WHEN: Performing the same action again in a second transacation
        let resultOfPutUniqueActionOnceAgain = application.putUniqueId(putUniqueIdAction)
        let secondRecorder = resultOfPutUniqueActionOnceAgain.completion.record()
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        let recordedThrownError: TransactionError = try wait(
            for: secondRecorder.expectError(),
            timeout: .enoughForPOW,
            description: "Performing same 'PutUniqueIdAction' twice in different transactions should throw error"
        )
        
        let putUniqueIdError = PutUniqueIdError.uniqueError(.rriAlreadyUsedByUniqueId(string: "foo"))
        let expectedError =  TransactionError.actionsToAtomError(
            ActionsToAtomError.putUniqueIdError(putUniqueIdError, action: putUniqueIdAction)
        )
        
        XCTAssertEqual(recordedThrownError, expectedError)
    }
    
    func testFailPuttingSameUniqueIdAsMutableToken() throws {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        
        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: alice, string: "FOO")
        
        // WHEN: Alice sends a `Transaction` containing a MutableSupplyToken and a UniqueId with the same RRI
        let transaction = Transaction {
            application.actionCreateMultiIssuanceToken(symbol: "FOO")
            putUniqueIdAction
        }
        
        let resultOfUniqueMaking = application.send(transaction: transaction)
        
        let recorder = resultOfUniqueMaking.completion.record()
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        let recordedThrownError: TransactionError = try wait(
            for: recorder.expectError(),
            timeout: .enoughForPOW,
            description: "Reusing same symbol should throw error"
        )
        
        let putUniqueIdError = PutUniqueIdError.uniqueError(.rriAlreadyUsedByMutableSupplyToken(identifier: ResourceIdentifier(address: alice, name: "FOO")))
        
        let expectedError =  TransactionError.actionsToAtomError(
            ActionsToAtomError.putUniqueIdError(putUniqueIdError, action: putUniqueIdAction)
        )
        
        XCTAssertEqual(recordedThrownError, expectedError)
    }
    
    func testFailPuttingSameUniqueIdAsFixedSupplyToken() throws {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: alice, string: "FOO")
        
        // WHEN: Alice sends a `Transaction` containing a FixedSupplyToken and a UniqueId with the same RRI
        let transaction = Transaction {
            application.actionCreateFixedSupplyToken(symbol: "FOO")
            putUniqueIdAction
        }
        
        let resultOfUniqueMaking = application.send(transaction: transaction)
        
        let recorder = resultOfUniqueMaking.completion.record()
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        let recordedThrownError: TransactionError = try wait(
            for: recorder.expectError(),
            timeout: .enoughForPOW,
            description: "Reusing same symbol should throw error"
        )
        
        let putUniqueIdError = PutUniqueIdError.uniqueError(.rriAlreadyUsedByFixedSupplyToken(identifier: ResourceIdentifier(address: alice, name: "FOO")))
        
        let expectedError =  TransactionError.actionsToAtomError(
            ActionsToAtomError.putUniqueIdError(putUniqueIdError, action: putUniqueIdAction)
        )
        
        XCTAssertEqual(recordedThrownError, expectedError)
    }
    
    func testFailAliceUsingBobsAddress() throws {
        // GIVEN: identities Alice and a Bob and a RadixApplicationClient connected to some Radix node
        let aliceApp = application!
        
        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: bob, string: "foo")
        
        // WHEN: Alice sends a Transaction containing a UniqueId specifying Bob’s address
        let transaction = Transaction {
            putUniqueIdAction
        }
        
        let resultOfUniqueMaking = aliceApp.send(transaction: transaction)
        
        let recorder = resultOfUniqueMaking.completion.record()
        
        // THEN: an error `nonMatchingAddress` is thrown
        let recordedThrownError: TransactionError = try wait(
            for: recorder.expectError(),
            timeout: .enoughForPOW,
            description: "Using someone else's address should throw error"
        )
        
        let putUniqueIdError = PutUniqueIdError.uniqueError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: bob))
        
        let expectedError =  TransactionError.actionsToAtomError(
            ActionsToAtomError.putUniqueIdError(putUniqueIdError, action: putUniqueIdAction)
        )
        
        XCTAssertEqual(recordedThrownError, expectedError)
    }
}

//extension TestCase {
//    func XCTAssertActionsToAtomError()
//}
