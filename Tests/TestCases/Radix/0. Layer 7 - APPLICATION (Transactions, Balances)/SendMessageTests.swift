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

class SendMessageTests: LocalhostNodeTest {
    
    private let aliceIdentity = AbstractIdentity(alias: "Alice")
    private let bobAccount = Account()
    private let claraAccount = Account()
    private let dianaAccount = Account()
    
    private lazy var application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: aliceIdentity)
    
    private lazy var alice = application.addressOfActiveAccount
    private lazy var bob = application.addressOf(account: bobAccount)
    private lazy var clara = application.addressOf(account: claraAccount)
    private lazy var diana = application.addressOf(account: dianaAccount)
    
    private let disposeBag = DisposeBag()
    
    func testSendNonEmptyPlainText() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send a non empty message without encryption
        application.pull().disposed(by: disposeBag)
        let message = "Hey Bob, this is plain text"
        let result = application.sendPlainTextMessage(message, to: bob)

        // THEN: I see that action completes successfully
        XCTAssertTrue(result.blockUntilComplete(timeout: .enoughForPOW))

        guard let sentMessage = application.observeMyMessages().blockingTakeLast(timeout: 2) else { return }
        let decryptedMessage = sentMessage.payload.toString()
        XCTAssertEqual(decryptedMessage, message)
        XCTAssertNotEqual(decryptedMessage, "foobar")
    }
    
    func testSendNonEmptyEncrypted() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send a non empty message with encryption
        let plainTextMessage = "Hey Bob, this is super secret message"
        let result = application.sendEncryptedMessage(plainTextMessage, to: bob)
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            result.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        guard let sentMessage = application.observeMyMessages().blockingTakeLast(timeout: 2) else { return }
        let decryptedMessage = sentMessage.payload.toString()
        XCTAssertEqual(decryptedMessage, plainTextMessage)
    }

    
    func testSendNonEmptyEncryptedThatAliceCannotDecrypt() {
        // GIVEN: A RadidxApplicationClient
        // WHEN: I send a non empty message with encryption
        let plainTextMessage = "Hey Bob, this is super secret message"
        let result = application.send(message: SendMessageAction.encrypted(from: alice, to: bob, onlyDecryptableBy: [bob], text: plainTextMessage))
        
        XCTAssertTrue(
            // THEN: I see that action completes successfully
            result.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        guard let sentMessage = application.observeMyMessages().blockingTakeLast(timeout: 2) else { return }
        XCTAssertTrue(sentMessage.encryptionState.isEncryptedButCannotDecrypt)
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
            message: SendMessageAction.encryptedDecryptableOnlyByRecipientAndSender(from: clara, to: bob, text: "Hey Bob, this is Clara.")
        )
 
        // THEN: I see that action fails with a validation error
        result.toCompletable().blockingAssertThrowsRPCErrorUnrecognizedJson(
            timeout: .enoughForPOW,
            expectedErrorType: ResultOfUserAction.Error.self,
            containingString: "message must be signed by sender: \(clara.address.base58String)"
        ) { $0.unrecognizedJsonStringFromError }
        
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
            result.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
    }
}

extension ResultOfUserAction.Error {
    var unrecognizedJsonStringFromError: String? {
        switch self {
        case .failedToSubmitAtom(let submitAtomError):
            return submitAtomError.rpcError.unrecognizedJsonStringFromError
        case .failedToStageAction: return nil
        }
    }
}

extension RPCError {
    var unrecognizedJsonStringFromError: String? {
        switch self {
            case .unrecognizedJson(let unrecognizeJsonString): return unrecognizeJsonString
            default: return nil
        }
    }
}

extension AbstractIdentity {
    convenience init(alias: String? = nil) {
        try! self.init(accounts: [Account()], alias: alias)
    }
    
    convenience init(privateKey: PrivateKey, alias: String? = nil) {
        try! self.init(accounts: [Account(privateKey: privateKey)], alias: alias)
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
        
        return self.toCompletable()
            .blockingAssertThrows(
                error: expectedError,
                timeout: timeout
        ) {
            guard let userActionError = $0 as? ResultOfUserAction.Error else {
                XCTFail("Expected `ResultOfUserAction.Error`")
                return nil
            }
            
            switch userActionError {
            case .failedToStageAction(let anyFailedToStageActionError):
                guard let failedToStageActionError = anyFailedToStageActionError.error as? SpecificError else {
                    XCTFail("Expected `SpecificError`")
                    return nil
                }
                return failedToStageActionError
            case .failedToSubmitAtom(let anySubmitAtomError):
                guard let submitAtomError = anySubmitAtomError as? SpecificError else {
                    XCTFail("Expected `SpecificError`")
                    return nil
                }
                return submitAtomError
            }
        }
    }
}
