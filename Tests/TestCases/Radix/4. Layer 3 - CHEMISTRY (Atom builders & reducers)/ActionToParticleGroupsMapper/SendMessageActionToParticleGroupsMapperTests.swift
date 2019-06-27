//
//  SendMessageActionToParticleGroupsMapperTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

enum DecryptMessageErrorInTest: Swift.Error, Equatable {
    case unknownError
}

extension AtomToDecryptedMessageMapper {
    
    func decryptMessage(in atom: Atom, account acountOwner: AccountOwner) throws -> DecryptedMessage {
        guard let decryptedMessage = self.map(atom: atom, account: acountOwner.account).blockingTakeFirst() else {
            throw DecryptMessageErrorInTest.unknownError
        }
        return decryptedMessage
    }
}

private let magic: Magic = 63799298

protocol AccountOwner {
    var account: Account { get }
}
extension Account: AccountOwner {
    var account: Account { return self }
}


private struct AccountWithAddress: SigningRequesting, Ownable, Equatable, AccountOwner {
    let address: Address
    let account: Account
    
    init(address: Address, account: Account) {
        self.address = address
        self.account = account
    }
    
    init() {
        let account = Account()
        let address = account.addressFromMagic(magic)
        self.init(address: address, account: account)
    }
}
extension AccountWithAddress {
    var privateKeyForSigning: SingleWanted<PrivateKey> {
        return account.privateKeyForSigning
    }
}

class SendMessageActionToParticleGroupsMapperTests: XCTestCase {
    
    private lazy var alice  = AccountWithAddress()
    private lazy var bob    = AccountWithAddress()
    private lazy var clara  = AccountWithAddress()
    private lazy var diana  = AccountWithAddress()
    
    func testEncryptAndDecryptMessage() {


        XCTAssertAllInequal(alice, bob, clara, diana)
        
        let message = "Hey Bob, this is your friend Alice, Clara should also be able to read this."
        let sendMessageAction = SendMessageAction.encryptedDecryptableBySenderAndRecipient(and: [clara], from: alice, to: bob, text: message)
        
        let mapper = DefaultSendMessageActionToParticleGroupsMapper()
        
        let particleGroupsForMessage = mapper.particleGroups(for: sendMessageAction)
        
        let mockedTimestamp = TimeConverter.dateFrom(millisecondsSince1970: 123456789)

        let atom = Atom(
            metaData: ChronoMetaData.timestamp(mockedTimestamp),
            particleGroups: particleGroupsForMessage
        )
        
        let atomToDecryptedMessagesMapper = DefaultAtomToDecryptedMessageMapper()

        func doTestResult(_ decryptedMessage: DecryptedMessage, expectedEncryptionState: DecryptedMessage.EncryptionState) {
            XCTAssertEqual(decryptedMessage.encryptionState, expectedEncryptionState)
            XCTAssertEqual(decryptedMessage.timestamp, mockedTimestamp)
            XCTAssertEqual(decryptedMessage.sender, alice.address)
            XCTAssertEqual(decryptedMessage.recipient, bob.address)
            if expectedEncryptionState == .decrypted {
                XCTAssertEqual(decryptedMessage.payload.toString(), message)
            }
        }

        func ensureEliglbeReaderCanDecrypt(_ account: AccountOwner) {
            
            do {
                let decryptedMessage = try atomToDecryptedMessagesMapper.decryptMessage(in: atom, account: account)
                  doTestResult(decryptedMessage, expectedEncryptionState: .decrypted)
            } catch {
                XCTFail("Eligible reader: \(account), should have been able to decrypt message, unexpected error: \(error)")
            }
        }
        
        let readers = [alice, bob, clara]
        readers.forEach {
            ensureEliglbeReaderCanDecrypt($0.account)
        }
        
        do {
            let dianasFeableAttemptToIntercept = try atomToDecryptedMessagesMapper.decryptMessage(in: atom, account: diana)
            doTestResult(dianasFeableAttemptToIntercept, expectedEncryptionState: .cannotDecrypt(error: ECIES.DecryptionError.keyMismatch))
        } catch {
            XCTFail("Even though Diana should not be able to read the clear text message, she should still be able to reduce a DecryptedMessage from an Atom, having still encrypted payload")
        }
    }
    
    func testThatOnlySenderAndRecipientCanDecryptMessageByDefault() {

        
        XCTAssertAllInequal(alice, bob, clara)
        
        let message = "Hey Bob, this is your friend Alice, only you and I should be able to read this"
        let sendMessageAction = SendMessageAction.encryptedDecryptableOnlyByRecipientAndSender(from: alice, to: bob, text: message)
        
        let mapper = DefaultSendMessageActionToParticleGroupsMapper()
        let atom = mapper.particleGroups(for: sendMessageAction).wrapInAtom()
        let atomToDecryptedMessagesMapper = DefaultAtomToDecryptedMessageMapper()

        func ensureCanBeDecrypted(by account: AccountOwner) {
            XCTAssertNotThrows(
                try atomToDecryptedMessagesMapper.decryptMessage(in: atom, account: account)
            ) { decryptedMessage in
                XCTAssertEqual(decryptedMessage.encryptionState, .decrypted)
                XCTAssertEqual(decryptedMessage.payload.toString(), message)
            }
        }
        
        ensureCanBeDecrypted(by: alice)
        ensureCanBeDecrypted(by: bob)
        
        XCTAssertNotThrows(
            try atomToDecryptedMessagesMapper.decryptMessage(in: atom, account: clara)
        ) { decryptedMessage in
            XCTAssertEqual(
                decryptedMessage.encryptionState,
                .cannotDecrypt(error: .keyMismatch))
        }
    }
    
    func testMessagesAreEncryptedByDefault() {

        let sendMessageAction = SendMessageAction(text: "Super secret message", from: alice, to: bob)
        XCTAssertTrue(sendMessageAction.shouldBeEncrypted)
    }
    
    func testNonEncryptedMessage() {
       
        XCTAssertAllInequal(alice, bob, clara)
        
        let message = "Hey Bob, this is your friend Alice, this message is not encrypted."
        let sendMessageAction = SendMessageAction.plainText(from: alice, to: bob, text: message)
        
        XCTAssertFalse(sendMessageAction.shouldBeEncrypted)
        let mapper = DefaultSendMessageActionToParticleGroupsMapper()
        let atom = mapper.particleGroups(for: sendMessageAction).wrapInAtom()
        let atomToDecryptedMessagesMapper = DefaultAtomToDecryptedMessageMapper()
        
        func ensureNonEncryptedMessageCanBeRead(by account: AccountOwner) {
            XCTAssertNotThrows(
                try atomToDecryptedMessagesMapper.decryptMessage(in: atom, account: account)
            ) { decryptedMessage in
                XCTAssertEqual(decryptedMessage.encryptionState, .wasNotEncrypted)
                XCTAssertEqual(decryptedMessage.payload.toString(), message)
            }
        }
        
        ensureNonEncryptedMessageCanBeRead(by: alice)
        ensureNonEncryptedMessageCanBeRead(by: bob)
        ensureNonEncryptedMessageCanBeRead(by: clara)
    }
    
}

extension Data {
    static var ignored: Data {
        return .empty
    }
}
