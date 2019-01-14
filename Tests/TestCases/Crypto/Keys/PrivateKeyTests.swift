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
  
    func testPerformanceOfBitcoinKitRestorationUsingMnemonic24Words() {
        measure {
            do {
                let seed = BitcoinKit.Mnemonic.seed(mnemonic: expected.seedWords)
                let wallet = BitcoinKit.HDWallet(seed: seed, network: expected.network)
                let privateKey = try wallet.privateKey(index: expected.hdWalletIndex)
                XCTAssertEqual(privateKey.toWIF(), expected.wif)
            } catch {
                return XCTFail("Key generation should not have throwed error: \(error)")
            }
        }
    }
    
    func testPerformanceOfBitcoinKitSignAndVerify() {
        let seed = BitcoinKit.Mnemonic.seed(mnemonic: expected.seedWords)
        let wallet = BitcoinKit.HDWallet(seed: seed, network: expected.network)
        let privateKey: BitcoinKit.PrivateKey
        let publicKey: BitcoinKit.PublicKey
        do {
            privateKey = try wallet.privateKey(index: expected.hdWalletIndex)
            publicKey = try wallet.publicKey(index: expected.hdWalletIndex)
            let publicKeyString = publicKey.description
            XCTAssertEqual(publicKeyString, expected.publicKey)
        } catch {
            return XCTFail("Key generation should not have throwed error: \(error)")
        }
        measure {
            do {
                let message = "Hello BitcoinKit".data(using: .utf8)!
                let _ = try BitcoinKit.Crypto.sign(message, privateKey: privateKey)
                // 10 % of the times the verification fails. This is not good.
                // I've created an issue at Github: https://github.com/yenom/BitcoinKit/issues/194
//                XCTAssertTrue(try BitcoinKit.Crypto.verifySignature(signatureData, message: message, publicKey: publicKey.raw))
            } catch {
                return XCTFail("Key generation should not have throwed error: \(error)")
            }
        }
    }
}

private let expected = (
    seedWords: ["economy", "clinic", "damage", "energy", "settle", "lady", "crumble", "crack", "valley", "blast", "hair", "double", "cute", "gather", "deer", "smooth", "finish", "ethics", "sauce", "raw", "novel", "hospital", "twice", "actual"],
    network: BitcoinKit.Network.mainnet,
    hdWalletIndex: UInt32(0),
    wif: "L5TEfWGHHUVyt16MbiZiQmANrz8zEaKW2EBKiZRfZ8hbEcy2ymGd",
    publicKey: "030cd0e6d332de86d3c964cac7e98c6b1330154433a8f8aa82a93cbc7a1bfdd45b"
)
