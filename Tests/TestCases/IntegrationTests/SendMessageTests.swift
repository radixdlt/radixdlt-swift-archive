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

class SendMessageTests: IntegrationTest {
    
    func testSendNonEmptyPlainText() throws {
        // GIVEN: A RadixApplicationClient
        
        // WHEN: I send a non empty message without encryption
        let message = "Hey Bob, this is plain text"
        let pendingTransaction = application.sendPlainTextMessage(message, to: bob)
        
        // THEN: I see that action completes successfully
        try waitForTransactionToFinish(pendingTransaction)
        
        let sentMessage = try waitForFirstValue(of: application.observeMyMessages())
        
        let decryptedMessage = sentMessage.textMessage()
        XCTAssertEqual(decryptedMessage, message)
    }
    
    func testSendNonEmptyEncrypted() throws {
        // GIVEN: A RadixApplicationClient
        // WHEN: I send a non empty message with encryption
        let plainTextMessage = "Hey Bob, this is super secret message"
        let pendingTransaction = application.sendEncryptedMessage(plainTextMessage, to: bob)
        
        try waitForTransactionToFinish(pendingTransaction)
        
        let sentMessage = try waitForFirstValue(of: application.observeMyMessages())
        XCTAssertEqual(sentMessage.textMessage(), plainTextMessage)
    }
    
    func testSendNonEmptyEncryptedThatAliceCannotDecrypt() throws {
        // GIVEN: A RadixApplicationClient
        // WHEN: I send a non empty message with encryption
        let plainTextMessage = "Hey Bob, this is super secret message"
        let pendingTransaction = application.sendMessage(
            action: SendMessageAction.encrypted(from: alice, to: bob, onlyDecryptableBy: [bob], text: plainTextMessage)
        )
        
        try waitForTransactionToFinish(pendingTransaction)
        
        let sentMessage = try waitForFirstValue(of: application.observeMyMessages())
        XCTAssertTrue(sentMessage.isEncryptedAndCannotDecrypt)
    }
    
    func testSendEmptyEncrypted() throws {
        // GIVEN: A RadixApplicationClient
        // WHEN: I send an empty message with encryption
        let pendingTransaction = application.sendEncryptedMessage("", to: bob)
        
        try waitForTransactionToFinish(pendingTransaction)
    }
    
    func testThatAliceCannotSendMessagesOnBobsBehalf() throws {
        // GIVEN: A RadixApplicationClient and identities Alice, Bob and Carol
        XCTAssertAllInequal(alice, bob, carol)
        
        // WHEN: Alice tries to send a message to Bob claiming to be from Carol
        let pendingTransaction = application.sendMessage(
            action: SendMessageAction.encryptedDecryptableOnlyByRecipientAndSender(from: carol, to: bob, text: "Hey Bob, this is Carol.")
        )
        
        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        try waitFor(
            messageSending: pendingTransaction,
            toFailWithError: .nonMatchingAddress(activeAddress: alice, butActionStatesAddress: carol)
        )
    }
    
    func testSendToThirdParties() throws {
        // GIVEN: A RadixApplicationClient and identities Alice, Bob and Carol
        XCTAssertAllInequal(alice, bob, carol)
        
        // WHEN: I send a non empty message with encryption
        let pendingTransaction = application.sendEncryptedMessage(
            "Hey Bob! Carol and Diana can also decrypt this encrypted message",
            to: bob,
            canAlsoBeDecryptedBy: [carol, diana]
        )
        
        try waitForTransactionToFinish(pendingTransaction)
    }
}


private extension SendMessageTests {
    
    func waitFor(
        messageSending pendingTransaction: PendingTransaction,
        toFailWithError sendMessageError: SendMessageError,
        description: String? = nil,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws {
        
        try waitForAction(
            ofType: SendMessageAction.self,
            in: pendingTransaction,
            description: description
        ) { sendMessageAction in
            
            TransactionError.actionsToAtomError(
                .sendMessageActionError(
                    sendMessageError,
                    action: sendMessageAction
                )
            )
        }
    }
}

