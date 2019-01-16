//
//  PrivateKeyTests.swift
//  RadixSDKTests
//
//  Created by Alexander Cyon on 2019-01-10.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit
import XCTest
@testable import RadixSDK

class PrivateKeyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testPerformanceOfBitcoinKitRestorationUsingMnemonic24Words() {
        measure {
            let seed = BitcoinKit.Mnemonic.seed(mnemonic: expected.seedWords)
            let wallet = BitcoinKit.HDWallet(seed: seed, network: expected.network)
            let privateKey = try! wallet.privateKey(index: expected.hdWalletIndex)
            XCTAssertEqual(privateKey.toWIF(), expected.wif)
        }
    }
    
    func testPerformanceOfBitcoinKitSignAndVerify() {
        let seed = BitcoinKit.Mnemonic.seed(mnemonic: expected.seedWords)
        let wallet = BitcoinKit.HDWallet(seed: seed, network: expected.network)
        let privateKey = try! wallet.privateKey(index: expected.hdWalletIndex)
        let publicKey = try! wallet.publicKey(index: expected.hdWalletIndex)
        let publicKeyString = publicKey.description
        XCTAssertEqual(publicKeyString, expected.publicKey)
        
        measure {
            let signatureData = try! BitcoinKit.Crypto.sign(message: expected.message, privateKey: privateKey)
            XCTAssertEqual(signatureData.hex, expected.signature)
            XCTAssertTrue(try! BitcoinKit.Crypto.verifySignature(signatureData, message: expected.messageHashedUTF8Encoded, publicKey: publicKey.raw))
        }
    }
 
}
private let messageText = "Hello BitcoinKit"
private let expected = (
    seedWords: ["economy", "clinic", "damage", "energy", "settle", "lady", "crumble", "crack", "valley", "blast", "hair", "double", "cute", "gather", "deer", "smooth", "finish", "ethics", "sauce", "raw", "novel", "hospital", "twice", "actual"],
    network: BitcoinKit.Network.mainnet,
    hdWalletIndex: UInt32(0),
    wif: "L5TEfWGHHUVyt16MbiZiQmANrz8zEaKW2EBKiZRfZ8hbEcy2ymGd",
    publicKey: "030cd0e6d332de86d3c964cac7e98c6b1330154433a8f8aa82a93cbc7a1bfdd45b",
    message: messageText,
    messageHashedUTF8Encoded: Crypto.sha256(messageText.data(using: .utf8)!),
    signature: "3045022100a1ce4f7b3a39685c546f9d54b987f9922c514f18d7d5e0bfd0c6dc097e62475802204e4fe33e9341246122770861bc5a39078b0dbcfc18e9b92b7229244aae11fc03"
)
