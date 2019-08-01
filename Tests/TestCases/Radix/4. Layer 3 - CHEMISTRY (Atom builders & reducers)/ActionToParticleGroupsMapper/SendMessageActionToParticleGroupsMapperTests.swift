/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import XCTest
@testable import RadixSDK
import RxSwift

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

        func doTestResult(_ decryptedMessage: SentMessage, expectedEncryptionState: SentMessage.EncryptionState) {
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
            XCTFail("Even though Diana should not be able to read the clear text message, she should still be able to reduce a SentMessage from an Atom, having still encrypted payload")
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

enum DecryptMessageErrorInTest: Swift.Error, Equatable {
    case unknownError
}

extension AtomToDecryptedMessageMapper {
    
    func decryptMessage(in atom: Atom, account acountOwner: AccountOwner) throws -> SentMessage {
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
    var privateKeyForSigning: Single<PrivateKey> {
        return account.privateKeyForSigning
    }
}

extension Data {
    static var ignored: Data {
        return .empty
    }
}
