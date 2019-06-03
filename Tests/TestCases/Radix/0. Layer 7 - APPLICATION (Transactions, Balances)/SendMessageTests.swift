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
    
    func testSendPlainText() {
        
        let request = application.sendMessage("Hey Bob, this is plain text", to: bob, encrypt: false)
        
        XCTAssertTrue(
            request.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW)
        )
    }
    
    func testSendEncrypted() {
        
        let request = application.sendMessage("Hey Bob, this is plain text", to: bob)
        
        XCTAssertTrue(
            request.blockingWasSuccessfull(timeout: RxTimeInterval.enoughForPOW)
        )
    }
    
    func testThatAliceCannotSendMessagesOnBobsBehalf() {
        
        let message = SendMessageAction(from: bob, to: clara, message: "This is Alice claiming to be Bob, trying to send a message to Clara")
        
        let request = application.sendMessage(message)
 
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
