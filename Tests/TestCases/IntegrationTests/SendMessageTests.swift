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
        // GIVEN: A RadidxApplicationClient
        
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
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send a non empty message with encryption
        let plainTextMessage = "Hey Bob, this is super secret message"
        let pendingTransaction = application.sendEncryptedMessage(plainTextMessage, to: bob)
     
        try waitForTransactionToFinish(pendingTransaction)
        
        let sentMessage = try waitForFirstValue(of: application.observeMyMessages())
        XCTAssertEqual(sentMessage.textMessage(), plainTextMessage)
    }
    
    /*
    func testSendNonEmptyEncryptedThatAliceCannotDecrypt() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send a non empty message with encryption
        let plainTextMessage = "Hey Bob, this is super secret message"
        let result = application.sendMessage(action: SendMessageAction.encrypted(from: alice, to: bob, onlyDecryptableBy: [bob], text: plainTextMessage))
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            result.blockingWasSuccessful(timeout: .enoughForPOW)
        )
        
        guard let sentMessage = application.observeMyMessages().blockingTakeLast() else { return }
        XCTAssertTrue(sentMessage.isEncryptedAndCannotDecrypt)
    }
    
    func testSendEmptyEncrypted() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send an empty message with encryption
        let result = application.sendEncryptedMessage("", to: bob)
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            result.blockingWasSuccessful(timeout: .enoughForPOW)
        )
    }
    
    func testThatAliceCannotSendMessagesOnBobsBehalf() {
        // GIVEN: A RadidxApplicationClient and identities Alice, Bob and Clara
        XCTAssertAllInequal(alice, bob, clara)
        
        // WHEN: Alice tries to send a message to Bob claming to be from Clara
        let result = application.send(
            message: SendMessageAction.encryptedDecryptableOnlyByRecipientAndSender(from: clara, to: bob, text: "Hey Bob, this is Clara.")
        )

        // THEN: an error `uniqueStringAlreadyUsed` is thrown
        result.blockingAssertThrows(
            error: SendMessageError.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: clara)
        )
        
    }
    
    func testSendToThirdParties() {
        // GIVEN: A RadidxApplicationClient and identities Alice, Bob and Clara
        XCTAssertAllInequal(alice, bob, clara)
        
        // WHEN: I send a non empty message with encryption
        let result = application.sendEncryptedMessage(
            "Hey Bob! Clara and Diana can also decrypt this encrypted message",
            to: bob,
            canAlsoBeDecryptedBy: [clara, diana]
        )
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            result.blockingWasSuccessful(timeout: .enoughForPOW)
        )
    }
 */
}
