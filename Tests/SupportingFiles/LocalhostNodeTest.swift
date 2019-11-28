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

class LocalhostNodeTest: TestCase {

    var aliceIdentity: AbstractIdentity!
    var bobAccount: Account!
    var application: RadixApplicationClient!
    var alice: Address!
    var bob: Address!
    var carolAccount: Account!
    var carol: Address!
    
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

    override func invokeTest() {
        guard isConnectedToLocalhost() else { return }
        super.invokeTest()
    }
    
}

extension LocalhostNodeTest {
    func waitForTransactionToFinish(
        _ pendingTransaction: PendingTransaction,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws {
        try wait(for: pendingTransaction.completion.record().finished, timeout: .enoughForPOW, description: "PendingTransaction should finish")
    }
    
    func waitForFirstValue<P>(
        of publisher: P,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws -> P.Output where P: Publisher {
        return try wait(for: publisher.record().firstOrError, timeout: .enoughForPOW, description: "First value of publisher")
    }
    
    func waitForAction<Action>(
        ofType _: Action.Type,
        in pendingTransaction: PendingTransaction,
        because description: String,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line,
        
        toFailWithError makeExpectedTransactionErrorFromAction: (Action) -> TransactionError
    ) throws where Action: UserAction {
        
        let action: Action = try XCTUnwrap(pendingTransaction.firstAction(), line: line)
        
        let recordedThrownError: TransactionError = try wait(
            for: pendingTransaction.completion.record().expectError(),
            timeout: timeout,
            description: description
        )
        
        let expectedError = makeExpectedTransactionErrorFromAction(action)
        
        XCTAssertEqual(
            recordedThrownError,
            expectedError,
            line: line
        )
    }
}
