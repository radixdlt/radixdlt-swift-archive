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
import RxBlocking

//private let magic: Magic = 63799298
//
//private extension RadixIdentity {
//    init() {
//        self.init(magic: magic)
//    }
//
//    init(privateKey: PrivateKey) {
//        self.init(private: privateKey, magic: magic)
//    }
//}


extension AbstractIdentity {
    convenience init(alias: String? = nil) {
        try! self.init(accounts: [Account()], alias: alias)
    }
}

extension Account {
    init() {
        let keyPair = KeyPair()
        self = .privateKeyPresent(keyPair)
    }
    
    init(privateKey: PrivateKey) {
        let keyPair = KeyPair(private: privateKey)
        self = .privateKeyPresent(keyPair)
    }
}

extension ResultOfUserAction {
    func blockingWasSuccessfull(
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnErrors: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Bool {
        
        return self.toCompletable().blockingWasSuccessfull(
            timeout: timeout,
            failOnTimeout: failOnTimeout,
            failOnErrors: failOnErrors,
            function: function, file: file, line: line
        )
        
    }
    
    func blockingAssertThrows<SpecificError>(
        error expectedError: SpecificError,
        timeout: TimeInterval? = .default
        ) where SpecificError: Swift.Error, SpecificError: Equatable {
        return self.toCompletable().blockingAssertThrows(error: expectedError, timeout: timeout)
    }
}

class SendMessageTests: LocalhostNodeTest {
    
    private let aliceIdentity = AbstractIdentity(alias: "Alice")
    private let bobAccount = Account()
    private let claraAccount = Account()
    private let dianaAccount = Account()
    
//    private lazy var application = DefaultRadixApplicationClient(node: .localhost, identity: alice, magic: magic)
    private lazy var application = DefaultRadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhost, identity: aliceIdentity)
    
    private lazy var alice: Address = {
        return application.addressOfActiveAccount
    }()
    
    private lazy var bob: Address = {
        return application.addressOf(account: bobAccount)
    }()
    
    private lazy var clara: Address = {
        return application.addressOf(account: claraAccount)
    }()
    
    private lazy var diana: Address = {
        return application.addressOf(account: dianaAccount)
    }()
    
    func testSendNonEmptyPlainText() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send a non empty message without encryption
        let result = application.sendPlainTextMessage("Hey Bob, this is plain text", to: bob) //.sendMessage("Hey Bob, this is plain text", to: bob, encryption: .plainText)
//        let request = application.sendMessage("Hey Bob, this is plain text", to: bob, encryption: .plainText)
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            result.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
    }
    
    func testSendNonEmptyEncrypted() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send a non empty message with encryption
        let result = application.sendEncryptedMessage("Hey Bob, this is super secret message", to: bob)
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            result.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
    }

    func testSendEmptyEncrypted() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send an empty message with encryption
        let result = application.sendEncryptedMessage("", to: bob)
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            result.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
    }
    
    func testThatAliceCannotSendMessagesOnBobsBehalf() {
        // GIVEN: A RadidxApplicationClient and identities Alice, Bob and Clara
        XCTAssertAllInequal(alice, bob, clara)
        
        // WHEN: Alice tries to send a message to Bob claming to be from Clara
        let result = application.send(
            message: SendMessageAction.encryptedDecryptableOnlyByRecipientAndSender(from: clara, to: bob, text: "Hey Bob, this is Clara."),
            ifNoSigningKeyPresent: .throwErrorDirectly
        )
 
        // THEN: I see that action fails with a validation error
        
        //            error: NodeInteractionError.atomNotStored(state: .validationError),
        result.blockingAssertThrows(
            error: SubmitAtomError(rpcError: RPCError.requestErrorCode(RPCErrorCode.invalidRequest)),
            timeout: .enoughForPOW
        )
    }
    
    func testSendToThirdParties() {
  
        // WHEN: I send a non empty message with encryption
        let result = application.sendEncryptedMessage(
            "Hey Bob! Clara and Diana can also decrypt this encrypted message",
            to: bob,
            canAlsoBeDecryptedBy: [clara, diana]
        )
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            result.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
    }
}

//extension SendMessageTests {
    // This ought to work in Radix Core, but does not, awaiting fix: https://radixdlt.atlassian.net/browse/RLAU-1342
    //    func testSendEmptyPlainText() {
    //        // GIVEN: A RadidxApplicationClient
    //        // WHEN: I send an empty message without encryption
    //        let request = application.sendMessage("", to: bob, encrypt: false)
    //
    //        XCTAssertTrue(
    //            // THEN: I see that action completes successfully
    //            request.blockingWasSuccessfull(timeout: .enoughForPOW)
    //        )
    //    }
//}

