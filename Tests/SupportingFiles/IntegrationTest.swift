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
import Combine
@testable import RadixSDK

class IntegrationTest: TestCase {

    var aliceIdentity = AbstractIdentity()
    
    // Same RadixApplicationClient for each test per test file, but changing
    // Alice's account before each test.
    lazy var aliceApp = RadixApplicationClient(
        bootstrapConfig: UniverseBootstrap.localhostTwoNodes,
        identity: aliceIdentity
    )
    
    var bobIdentity: AbstractIdentity!
    var alice: Address!
    var bob: Address!
    var carolAccount: Account!
    var carol: Address!
    var dianaAccount = Account()
    var diana: Address!
    
    override func setUp() {
        super.setUp()
        
        aliceIdentity = AbstractIdentity()
        
        // New account before each test.
        aliceApp.changeAccount(to: aliceIdentity.snapshotActiveAccount)
        
        bobIdentity = AbstractIdentity()
        carolAccount = Account()
      
        alice = aliceApp.addressOfActiveAccount
        bob = aliceApp.addressOf(account: bobIdentity.snapshotActiveAccount)
        carol = aliceApp.addressOf(account: carolAccount)
        diana = aliceApp.addressOf(account: dianaAccount)
    }

    override func invokeTest() {
        guard isConnectedToLocalhost() else { return }
        super.invokeTest()
    }
}

extension IntegrationTest {
    func waitForTransactionToFinish(
        _ pendingTransaction: PendingTransaction,
        timeout: TimeInterval = .enoughForPOW,
        
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try wait(
            for: pendingTransaction.completion.record().finished,
            timeout: timeout,
            description: "PendingTransaction should finish",

            file: file,
            line: line
        )
    }
    
    func waitForFirstValue<P>(
        of publisher: P,
        timeout: TimeInterval = .enoughForPOW,
        description: String? = nil,
     
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> P.Output where P: Publisher {
        
        return try wait(
            for: publisher.record().firstOrError,
            timeout: timeout,
            description: description ?? "First value of publisher, or error",

            file: file,
            line: line
        )
    }
    
    func waitForFirstSequence<P>(
        of publisher: P,
        timeout: TimeInterval = .enoughForPOW,
        description: String? = nil,

        file: StaticString = #file,
        line: UInt = #line
    ) throws -> [P.Output.Element] where P: Publisher, P.Output: Sequence {
        
        return try wait(
            for: publisher.record().firstSequenceOrError,
            timeout: timeout,
            description: description ?? "First sequence of publisher, or error",

            file: file,
            line: line
        )
    }
    
    func waitFor<P>(
        first numberOfValuesToWaitFor: Int,
        valuesPublishedBy publisher: P,
        timeout: TimeInterval = .enoughForPOW,
        description: String? = nil,

        file: StaticString = #file,
        line: UInt = #line
    ) throws -> [P.Output] where P: Publisher {
        
        return try wait(
            for: publisher.record().prefixedOrError(numberOfValuesToWaitFor),
            timeout: timeout,
            description: description ?? "First \(numberOfValuesToWaitFor) values of publisher, or error",

            file: file,
            line: line
        )
    }
    
    func waitForFirstValueUnwrapped<P>(
        of publisher: P,
        timeout: TimeInterval = .enoughForPOW,

        file: StaticString = #file,
        line: UInt = #line
    ) throws -> P.Output.Wrapped where P: Publisher, P.Output: OptionalType {
        
        let first: P.Output = try waitForFirstValue(of: publisher, timeout: timeout, file: file, line: line)
        
        return try XCTUnwrap(first.value, file: file, line: line)
    }
    
    func waitForAction<Action>(
        ofType _: Action.Type,
        atIndex actionIndex: Int = 0,
        in pendingTransaction: PendingTransaction,
        description: String? = nil,
        timeout: TimeInterval = .enoughForPOW,
        
        file: StaticString = #file,
        line: UInt = #line,
        
        toFailWithError makeExpectedTransactionErrorFromAction: (Action) -> TransactionError
    ) throws where Action: UserAction {
        
        let actions = try XCTUnwrap(pendingTransaction.actions(ofType: Action.self), file: file, line: line)
        
        XCTAssertGreaterThan(
            actions.count, actionIndex,
            file: file,
            line: line
        )
        
        let action = actions[actionIndex]

        let expectedError = makeExpectedTransactionErrorFromAction(action)
        
        let recordedThrownError: TransactionError = try wait(
            for: pendingTransaction.completion.record().expectError(),
            timeout: timeout,
            description: description ?? "Wait for expected error: '\(expectedError)'",

            file: file,
            line: line
        )
        
        XCTAssertEqual(
            recordedThrownError,
            expectedError,

            file: file,
            line: line
        )
    }
}
