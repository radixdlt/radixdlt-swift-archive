//
//  SendMessageTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-06-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK
import RxSwift
import RxTest

class SendMessageTests: WebsocketTest {
    
    private let alice = RadixIdentity()
    private let bob = RadixIdentity()
    private let clara = RadixIdentity()
    
    private lazy var application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
    
    func testSendNonEmptyPlainText() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send a non empty message without encryption
        let request = application.sendMessage("Hey Bob, this is plain text", to: bob, encrypt: false)
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            request.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW)
        )
    }
    
    // This ought to work in Radix Core, but does not, awaiting fix: https://radixdlt.atlassian.net/browse/RLAU-1342
//    func testSendEmptyPlainText() {
//        // GIVEN: A RadidxApplicationClient
//        // WHEN: I send an empty message without encryption
//        let request = application.sendMessage("", to: bob, encrypt: false)
//
//        XCTAssertTrue(
//            // THEN: I see that action completes successfully
//            request.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW)
//        )
//    }
    
    func testSendNonEmptyEncrypted() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send a non empty message with encryption
        let request = application.sendMessage("Hey Bob, this is super secret message", to: bob, encrypt: true)
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            request.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW)
        )
    }
    
    
    func testSendEmptyEncrypted() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send an empty message with encryption
        let request = application.sendMessage("", to: bob, encrypt: true)
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            request.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW)
        )
    }
    
    func testThatAliceCannotSendMessagesOnBobsBehalf() {
        // GIVEN: A RadidxApplicationClient and identities Alice, Bob and Clara
        XCTAssertAllInequal(alice, bob, clara)
        
        // WHEN: Alice tries to send a message to Bob claming to be from Clara
        let request = application.sendMessage(
            SendMessageAction(from: clara, to: bob, message: "Hey Bob, this is Clara.")
        )
 
        // Then: I see that action fails with a validation error
        request.blockingAssertThrows(
            error: NodeInteractionError.atomNotStored(state: .validationError),
            timeout: RxTimeInterval.enoughForPOW
        )
        
    }
}

private let magic: Magic = 63799298

private extension RadixIdentity {
    init() {
        self.init(magic: magic)
    }
    
    init(privateKey: PrivateKey) {
        self.init(private: privateKey, magic: magic)
    }
}
