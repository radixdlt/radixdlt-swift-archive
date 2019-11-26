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
        let resultOfPutUniqueAction = try application.send(transaction: transaction)
        
        let recorderCompletable = resultOfPutUniqueAction.completable.record()
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
        
        let resultOfPutUniqueActions = try application.send(transaction: transaction)
        let recorderCompletable = resultOfPutUniqueActions.completable.record()
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

        // WHEN: Alice sends a `Transaction` containing two UniqueId with with the same string
        let transaction = Transaction {
            PutUniqueIdAction(uniqueMaker: alice, string: "foo")
            PutUniqueIdAction(uniqueMaker: alice, string: "foo")
        }

//        let resultOfPutUniqueActions = try application.send(transaction: transaction)
//        
//        let recorderCompletable = resultOfPutUniqueActions.completable.record()
//        
//        // THEN: an error `uniqueStringAlreadyUsed` is thrown
//        XCTAssertThrowsSpecificError(
//            try wait(for: recorderCompletable.expectError(ofType: PutUniqueIdError.self), timeout: .enoughForPOW),
//            PutUniqueIdError.uniqueError(.rriAlreadyUsedByUniqueId(string: "foo"))
//        )
        


//        XCTAssertThrowsSpecificError(
//            try resultOfUniqueMaking.blockingRethrow(timeout: .enoughForPOW) { XCTFail("Should not have timed out \($0)") },
//            PutUniqueIdError.uniqueError(.rriAlreadyUsedByUniqueId(string: "foo"))
//        )
        
    }
    
    
    /*
    func testFailPuttingAnUniqueIdUsedInAPreviousTransaction() {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        
        let putUniqueAction = PutUniqueIdAction(uniqueMaker: alice, string: "foo")
        
        XCTAssertTrue(
           application.putUniqueId(putUniqueAction)
                .blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        application.putUniqueId(putUniqueAction).blockingAssertThrows(
            error: PutUniqueIdError.uniqueError(.rriAlreadyUsedByUniqueId(string: "foo"))
        )
    }
    
    func testFailPuttingSameUniqueIdAsMutableToken() {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        
        // WHEN: Alice sends a `Transaction` containing a MutableSupplyToken and a UniqueId with the same RRI
        let transaction = Transaction {
            application.actionCreateMultiIssuanceToken(symbol: "FOO")
            PutUniqueIdAction(uniqueMaker: alice, string: "FOO")
        }
        
        let resultOfUniqueMaking = application.send(transaction: transaction)
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        resultOfUniqueMaking.blockingAssertThrows(
            error: PutUniqueIdError.uniqueError(.rriAlreadyUsedByMutableSupplyToken(identifier: ResourceIdentifier(address: alice, name: "FOO")))
        )
    }
    
    func testFailPuttingSameUniqueIdAsFixedSupplyToken() {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        
        // WHEN: Alice sends a `Transaction` containing a FixedSupplyToken and a UniqueId with the same RRI
        let transaction = Transaction {
            application.actionCreateFixedSupplyToken(symbol: "FOO")
            PutUniqueIdAction(uniqueMaker: alice, string: "FOO")
        }
        
        let resultOfUniqueMaking = application.send(transaction: transaction)
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        resultOfUniqueMaking.blockingAssertThrows(
            error: PutUniqueIdError.uniqueError(.rriAlreadyUsedByFixedSupplyToken(identifier: ResourceIdentifier(address: alice, name: "FOO")))
        )
    }
    
    func testFailAliceUsingBobsAddress() {
        // GIVEN: dentities Alice and a Bob and a RadixApplicationClient connected to some Radix node
        let aliceApp = application!
        
        // WHEN: Alice sends a Transaction containing a UniqueId specifying Bob’s address
        let transaction = Transaction {
            PutUniqueIdAction(uniqueMaker: bob, string: "foo")
        }
        
        let resultOfUniqueMaking = aliceApp.send(transaction: transaction)
        
        // THEN: an error `nonMatchingAddress` is thrown
        resultOfUniqueMaking.blockingAssertThrows(
            error: PutUniqueIdError.uniqueError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: bob))
        )
    }
 */
}

