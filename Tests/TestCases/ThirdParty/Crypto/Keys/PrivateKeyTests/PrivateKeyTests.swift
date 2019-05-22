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
    
    func testSeeds() {
        let first =  BitcoinKit.Mnemonic.seed(mnemonic: ["increase", "spy", "seminar", "avocado", "rack", "predict", "fine", "worry", "minor", "depth", "render", "picture"])
        XCTAssertEqual(first.hex, "716a00b93ee5db0c64c341c1d7d7e92cd9a3579526658cb28e40ce5d6d19c82b757ee532d38d380162ff44e6c3062ffe8d323d1600158136a20f03f865532567")
        let second = BitcoinKit.Mnemonic.seed(mnemonic: ["fit", "shock", "trip", "pelican", "cave", "fiscal", "grass", "private", "play", "glow", "margin", "snow"])
        
        XCTAssertEqual(second.hex, "34ccaa37089fa9e9346ad5e6a3c19972e32c4935f9ef1c30ca01b29870110cb9fa60f96b6758d68c84671de134502e4139c20c0387d5c86d8e76ffd05990d84a")
        
        let third = BitcoinKit.Mnemonic.seed(mnemonic: ["minimum", "where", "edge", "win", "state", "antique", "cattle", "follow", "army", "life", "spoon", "gain"])

        XCTAssertEqual(third.hex, "c4f99552b187e98f9410137ccfe60b314e71184648281f6ba8774d93b9c9fb00c0d12b63cc5ab4375b4f1b24727db2ef94bb415f61bc737effebfe7e7dbc56d8")
    }
  
    func testBitcoinKitGenerate12Mneominic() {
        let words = try! BitcoinKit.Mnemonic.generate(strength: Mnemonic.Strength.default, language: Mnemonic.Language.english)
        XCTAssertEqual(words.count, 12)
    }
    
    func testBitcoinKitPerformanceOfSignAndVerify() {
        let magic: Magic = 2
        let seed = BitcoinKit.Mnemonic.seed(mnemonic: expected.seedWords)
        let wallet = BitcoinKit.HDWallet(seed: seed, network: expected.network)
        let privateKeyBicoinKit = try! wallet.privateKey(index: expected.hdWalletIndex)
        let privateKey = try! PrivateKey(data: privateKeyBicoinKit.data)
        XCTAssertEqual(privateKey.hex, "3737eade55463b1cbae340bb3bc770d42a6e54a39e3fd92c080b1621b170eb03")
        let identity = RadixIdentity(private: privateKey, magic: magic)
        let address = Address(
            magic: magic,
            publicKey: identity.publicKey
        )
        XCTAssertEqual(address.full, "JEqnJtuyrXLkEDRT6ADTGSMe6etWyKNVdffC5icSh4hWhJYcvCx")
        let publicKey = PublicKey(private: privateKey)
        XCTAssertEqual(publicKey.description, expected.publicKey)
        
        measure {
            do {
                
                let message = try Message(data: expected.messageHashedUTF8Encoded)
                
                let signature = try Signer.sign(message, privateKey: privateKey)
                XCTAssertEqual(try signature.toDER().hex, expected.signature)
             
                XCTAssertTrue(try SignatureVerifier.verifyThat(signature: signature, signedMessage: message, usingKey: publicKey))
            } catch {
                XCTFail("error: \(error)")
            }
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
    messageHashedUTF8Encoded: Crypto.sha256(messageText.toData()),
    signature: "3045022100d91b331dd05b4e0c298c6b408a1697a47053156b07e6113e97bef396fe5eaeb702202f14d9f28e207338f752fe6921835645848f310f9fe86040032b5c61e69add64"
)
