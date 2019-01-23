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
    
    func testBitcoinKitPerformanceOfRestorationUsingMnemonic24Words() {
        measure {
            let seed = BitcoinKit.Mnemonic.seed(mnemonic: expected.seedWords)
            let wallet = BitcoinKit.HDWallet(seed: seed, network: expected.network)
            let privateKey = try! wallet.privateKey(index: expected.hdWalletIndex)
            XCTAssertEqual(privateKey.toWIF(), expected.wif)
        }
    }
    
    func testBitcoinKitPerformanceOfSignAndVerify() {
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
    network: BitcoinKit.Network.testnetBTC,
    hdWalletIndex: UInt32(0),
    wif: "cPS3DcP8WFCwJnyeqHDF8LkLNCeqEP3PaNm6QvbnZ9mbJ7wKNP5w",
    publicKey: "025b29b14985d1e22fa22146072c643f449b5ebc0117cea585625c75270baf9fcf",
    message: messageText,
    messageHashedUTF8Encoded: Crypto.sha256(messageText.data(using: .utf8)!),
    signature: "3045022100d91b331dd05b4e0c298c6b408a1697a47053156b07e6113e97bef396fe5eaeb702202f14d9f28e207338f752fe6921835645848f310f9fe86040032b5c61e69add64"
)
