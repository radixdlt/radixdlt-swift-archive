//
//  SendMessageActionToParticleGroupsMapperTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class SendMessageActionToParticleGroupsMapperTests: XCTestCase {
    
    func testEncryptAndDecryptMessage() {
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let clara = RadixIdentity()
        let diana = RadixIdentity()

        XCTAssertAllInequal(alice, bob, clara, diana)
        
        let message = "Hey Bob, this is your friend Alice, Clara should also be albe "
        let sendMessageAction = SendMessageAction(from: alice, to: bob, message: message, shouldBeEncrypted: true)
        
        let readers = [alice, bob, clara]
        
        let mapper = DefaultSendMessageActionToParticleGroupsMapper { _ in
            readers.map { $0.publicKey }
        }
        
        let particleGroupsForMessage = mapper.particleGroups(for: sendMessageAction)
        
        let mockedTimestamp = TimeConverter.dateFrom(millisecondsSince1970: 123456789)

        let atom = Atom(
            metaData: ChronoMetaData.timestamp(mockedTimestamp),
            particleGroups: particleGroupsForMessage
        )
        
        let reducer = DefaultDecryptMessageReducer()

        func doTestResult(_ decryptedMessage: DecryptedMessage, expectedEncryptionState: DecryptedMessage.EncryptionState) {
            XCTAssertEqual(decryptedMessage.encryptionState, expectedEncryptionState)
            XCTAssertEqual(decryptedMessage.timestamp, mockedTimestamp)
            XCTAssertEqual(decryptedMessage.sender, alice.address)
            XCTAssertEqual(decryptedMessage.recipient, bob.address)
            if expectedEncryptionState == .decrypted {
                XCTAssertEqual(decryptedMessage.payload.toString(), message)
            }
        }

        func ensureEliglbeReaderCanDecrypt(_ identity: RadixIdentity) {
            
            do {
                let decryptedMessage = try reducer.decryptMessage(in: atom, using: identity)
                  doTestResult(decryptedMessage, expectedEncryptionState: .decrypted)
            } catch {
                XCTFail("Eligible reader: \(identity), should have been able to decrypt message, unexpected error: \(error)")
            }
        }
        
        readers.forEach {
            ensureEliglbeReaderCanDecrypt($0)
        }
        
        do {
            let dianasFeableAttemptToIntercept = try reducer.decryptMessage(in: atom, using: diana)
            doTestResult(dianasFeableAttemptToIntercept, expectedEncryptionState: .cannotDecrypt(error: ECIES.DecryptionError.keyMismatch))
        } catch {
            XCTFail("Even though Diana should not be able to read the clear text message, she should still be able to reduce a DecryptedMessage from an Atom, having still encrypted payload")
        }
    }
    
    func testThatOnlySenderAndRecipientCanDecryptMessageByDefault() {
        let alice = RadixIdentity()
        let bob = RadixIdentity()
        let clara = RadixIdentity()
        
        XCTAssertAllInequal(alice, bob, clara)
        
        let message = "Hey Bob, this is your friend Alice, only you and I should be able to read this"
        let sendMessageAction = SendMessageAction(from: alice, to: bob, message: message, shouldBeEncrypted: true)
        let mapper = DefaultSendMessageActionToParticleGroupsMapper()
        let atom = mapper.particleGroups(for: sendMessageAction).wrapInAtom()
        let reducer = DefaultDecryptMessageReducer()

        func ensureCanBeDecrypted(by identity: RadixIdentity) {
            XCTAssertNotThrows(
                try reducer.decryptMessage(in: atom, using: identity)
            ) { decryptedMessage in
                XCTAssertEqual(decryptedMessage.encryptionState, .decrypted)
                XCTAssertEqual(decryptedMessage.payload.toString(), message)
            }
        }
        
        ensureCanBeDecrypted(by: alice)
        ensureCanBeDecrypted(by: bob)
        
        XCTAssertNotThrows(
            try reducer.decryptMessage(in: atom, using: clara)
        ) { decryptedMessage in
            XCTAssertEqual(
                decryptedMessage.encryptionState,
                .cannotDecrypt(error: .keyMismatch))
        }
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

extension Data {
    static var ignored: Data {
        return .empty
    }
}
