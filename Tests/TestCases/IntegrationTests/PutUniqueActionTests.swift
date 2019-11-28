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

class PutUniqueIdActionTests: IntegrationTest {
    
    func testSendTransactionWithSingleUniqueId() throws {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node

        // WHEN: Alice sends a `Transaction` containing a `UniqueId` with the string `"foobar"`
        let transaction = Transaction {
            PutUniqueIdAction(uniqueMaker: alice, string: "foobar")
        }
        
        let pendingTransaction = application.make(transaction: transaction)
        try waitForTransactionToFinish(pendingTransaction)
        
        let executedTransaction = try waitForFirstValue(
            of: application.observeTransactions(at: alice, containingActionOfAnyType: [PutUniqueIdAction.self])
        )

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
        
        let pendingTransaction = application.make(transaction: transaction)
        try waitForTransactionToFinish(pendingTransaction)
        
        let executedTransaction = try waitForFirstValue(
            of: application.observeTransactions(at: alice, containingActionOfAnyType: [PutUniqueIdAction.self])
        )
        
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

        let pendingTransaction = application.make(transaction: transaction)
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        try waitFor(
            pendingTransaction: pendingTransaction,
            toFailWithError: .uniqueError(.rriAlreadyUsedByUniqueId(string: "foo")),
            because: "Transaction containing two identical 'PutUniqueIdAction' should throw error"
        )
    }
    
    
    func testFailPuttingAnUniqueIdUsedInAPreviousTransaction() throws {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: alice, string: "foo")
        try  waitForTransactionToFinish(application.putUniqueId(action: putUniqueIdAction))
        
        // WHEN: Performing the same action again in a second transaction
        let pendingTransaction = application.putUniqueId(action: putUniqueIdAction)
        
        try waitFor(
            pendingTransaction: pendingTransaction,
            toFailWithError: .uniqueError(.rriAlreadyUsedByUniqueId(string: "foo")),
            because: "Transaction containing two identical 'PutUniqueIdAction' should throw error"
        )
    }
    
    func testFailPuttingSameUniqueIdAsMutableToken() throws {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        
        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: alice, string: "FOO")
        
        // WHEN: Alice sends a `Transaction` containing a MutableSupplyToken and a UniqueId with the same RRI
        let transaction = Transaction {
            application.actionCreateMultiIssuanceToken(symbol: "FOO")
            putUniqueIdAction
        }
        
        let pendingTransaction = application.make(transaction: transaction)
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        try waitFor(
            pendingTransaction: pendingTransaction,
            toFailWithError: .uniqueError(.rriAlreadyUsedByMutableSupplyToken(identifier: ResourceIdentifier(address: alice, name: "FOO"))),
            because: "Reusing same symbol should throw error"
        )
    }
    
    func testFailPuttingSameUniqueIdAsFixedSupplyToken() throws {
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: alice, string: "FOO")
        
        // WHEN: Alice sends a `Transaction` containing a FixedSupplyToken and a UniqueId with the same RRI
        let transaction = Transaction {
            application.actionCreateFixedSupplyToken(symbol: "FOO")
            putUniqueIdAction
        }
        
        let pendingTransaction = application.make(transaction: transaction)
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        try waitFor(
            pendingTransaction: pendingTransaction,
            toFailWithError: .uniqueError(.rriAlreadyUsedByFixedSupplyToken(identifier: ResourceIdentifier(address: alice, name: "FOO"))),
            because: "Reusing same symbol should throw error"
        )
    }
    
    func testFailAliceUsingBobsAddress() throws {
        // GIVEN: identities Alice and a Bob and a RadixApplicationClient connected to some Radix node
        let aliceApp = application!
        
        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: bob, string: "foo")
        
        // WHEN: Alice sends a Transaction containing a UniqueId specifying Bob’s address
        let transaction = Transaction {
            putUniqueIdAction
        }
        
        let pendingTransaction = aliceApp.make(transaction: transaction)
        
        
        // THEN: an error `nonMatchingAddress` is thrown
        try waitFor(
            pendingTransaction: pendingTransaction,
            toFailWithError: .uniqueError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: bob)),
            because: "Using someone else's address should throw error"
        )
    }
}

private extension PutUniqueIdActionTests {

    func waitFor(
        pendingTransaction: PendingTransaction,
        toFailWithError putUniqueIdError: PutUniqueIdError,
        because description: String,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws {
        
        try waitForAction(
            ofType: PutUniqueIdAction.self,
            in: pendingTransaction,
            because: description
        ) { putUniqueIdAction in
            
            TransactionError.actionsToAtomError(
                .putUniqueIdActionError(
                    putUniqueIdError,
                    action: putUniqueIdAction
                )
            )
        }
    }
}
