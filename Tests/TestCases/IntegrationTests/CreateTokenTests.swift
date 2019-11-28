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

class CreateTokenTests: IntegrationTest {

    func testFailingCreateTokenInSomeoneElseʼsName() throws {
        // GIVEN: An Application API owned by Alice, and identity Bob
        let aliceApp = application!
        
        // WHEN: Alice tries to create a token on Bob's behalf
        let (tokenCreation, _) = aliceApp.createToken(creator: bob)
        
        // THEN: We get an error
        try waitFor(
            tokenCreation: tokenCreation,
            toFailWithError: .uniqueActionError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: bob))
        )
    }
    
    func testFailCreatingTokenWithSameRRIAsUniqueId() throws {
        // GIVEN: An Application API owned by Alice, and identity Bob
        let aliceApp = application!
        
        let createTokenAction =
            application.actionCreateToken(symbol: "FOO")
        
        let rri = createTokenAction.identifier
        
        let transaction = Transaction {
            PutUniqueIdAction(uniqueMaker: alice, string: "FOO")
            createTokenAction
        }
        
        let tokenCreation = aliceApp.make(transaction: transaction)
        
        // THEN: We get an error
        try waitFor(
            tokenCreation: tokenCreation,
            toFailWithError: .uniqueActionError(.rriAlreadyUsedByUniqueId(string: rri.name))
        )
    }
    
    
    func testFailCreatingTokenWithSameRRIAsExistingMutableSupplyToken() throws {
        // GIVEN: An Application API owned by Alice, and identity Bob
        let aliceApp = application!
        
        let symbol: Symbol = "FOO"
        let actionCreateMutableToken = application.actionCreateMultiIssuanceToken(symbol: symbol)
        
        let transaction = Transaction {
            actionCreateMutableToken
            application.actionCreateToken(symbol: symbol)
        }
        
        let tokenCreation = aliceApp.make(transaction: transaction)
        
        // THEN: We get an error
        try waitFor(
            tokenCreation: tokenCreation,
            toFailWithError: .uniqueActionError(.rriAlreadyUsedByMutableSupplyToken(identifier: actionCreateMutableToken.identifier))
        )
    }
    
    func testFailCreatingTokenWithSameRRIAsExistingFixedSupplyToken() throws {
        // GIVEN: An Application API owned by Alice, and identity Bob
        let aliceApp = application!
        
        let symbol: Symbol = "FOO"
        let actionCreateFixedToken = application.actionCreateFixedSupplyToken(symbol: symbol)
        
        let transaction = Transaction {
            actionCreateFixedToken
            application.actionCreateToken(symbol: symbol)
        }

        let tokenCreation = aliceApp.make(transaction: transaction)
        
        // THEN: We get an error
        try waitFor(
            tokenCreation: tokenCreation,
            toFailWithError: .uniqueActionError(.rriAlreadyUsedByFixedSupplyToken(identifier: actionCreateFixedToken.identifier)),
            becauseOfActionAtIndex: 1
        )
    }
    
}

private extension CreateTokenTests {
    
    func waitFor(
        tokenCreation pendingTransaction: PendingTransaction,
        toFailWithError createTokenError: CreateTokenError,
        becauseOfActionAtIndex actionIndex: Int = 0,
        description: String? = nil,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws {
        
        try waitForAction(
            ofType: CreateTokenAction.self,
            atIndex: actionIndex,
            in: pendingTransaction,
            description: description
        ) { createTokenAction in
            
            TransactionError.actionsToAtomError(
                .createTokenActionError(
                    createTokenError,
                    action: createTokenAction
                )
            )
        }
    }
}
