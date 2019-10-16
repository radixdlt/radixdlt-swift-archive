//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    
    // MARK: - MOTION... HIP
    // MARK: TESTNET
    // MARK: No passphrase
    func test_testnet__Motion_Hip__no_passphrase_index_0() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "",
            index: 0,
            expectedPrivateKey: "900ccb6b2136dc7821e6edd6bf0cbbf182c753d19e8be2bd567d2a5c9d57ef6c",
            network: .testnetBTC,
            expectedAddress: "JFCqwzgrKMgGQVMeGpzeGmQG2Nowy9o1gwv9X5Gyg7z5XK1XwBq")
    }
    
    func test_testnet__Motion_Hip__no_passphrase_index_1() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "",
            index: 1,
            expectedPrivateKey: "49408cb9f102c550ad816eecc9bf80bd35592f5e5edeb7fff4139aa2a6c95923",
            network: .testnetBTC,
            expectedAddress: "JHRvmeA4oGBk65QKSxBALAvm8G1L6mE6Kpi74eYKpm6Sz1XobtN"
        )
    }
    
    func test_testnet__Motion_Hip__no_passphrase_index_1337() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "",
            index: 1337,
            expectedPrivateKey: "39e02fdcab4dc3c065db44b96aa55715df8ec57047254b4aca4775ebb148a70e",
            network: .testnetBTC,
            expectedAddress: "JFobjoiq7LbCWNRuxM3Vikb7aYRwB2wEpSvfhqR2hgWfS2Pk6iV"
        )
    }
    
    // MARK: Passhrases
    func test_testnet__Motion_Hip__passphrase_foobar_index_0() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "foobar",
            index: 0,
            expectedPrivateKey: "f865dbcb513d463c780331a8eb16b96929168cf609f68168b165ce711af74ed4",
            network: .testnetBTC,
            expectedAddress: "JFXLdVEtsDP8nG7qkUkS68VeL9EV586SZEV6LvjrpEtksHNbaSC")
    }
    
    func test_testnet__Motion_Hip__passphrase_foobar_index_1() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "foobar",
            index: 1,
            expectedPrivateKey: "dc614794c16118a981954f0e2a58b5eea1a2fe11bbf1ce9b4b80531130bd38a1",
            network: .testnetBTC,
            expectedAddress: "JGwtDw9uSsY66vNqNZWLb8UU3Q9eeMtkHmfws6zicLH7CYer3cn"
        )
    }
    
    func test_testnet__Motion_Hip__passphrase_foobar_index_1337() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "foobar",
            index: 1337,
            expectedPrivateKey: "257aa52acf8b0c4829ccdafe26660ffd037d79691abca17791a54d94633ec21d",
            network: .testnetBTC,
            expectedAddress: "JHGgyc2fGUwYEE9BonsFYvG8EH8yX6m4RDEFX2xeuhBBseLgzCb"
        )
    }
    
    // MARK: MAINNET
    // MARK: No passphrase
    func test_mainnet__Motion_Hip__no_passphrase_index_0() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "",
            index: 0,
            expectedPrivateKey: "f4502ffee734e2550beab37d3d7d45186cbc02d99ff124a19de333362396589b",
            expectedAddress: "JGpR4tMXRngjpdf5Dt7SZhKB1kzW5Ma9RMgVQArr2MWKsQRxrFR")
    }
    
    func test_mainnet__Motion_Hip__no_passphrase_index_1() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "",
            index: 1,
            expectedPrivateKey: "0f3f5de07179a964836a37501919707958e0dde98747c9872ddde3139d531b16",
            expectedAddress: "JFGWA7RvUEo4CvhhEmBjo85unhEDQ9Y8Q5525JP3e1eomYUux11"
        )
    }
    
    func test_mainnet__Motion_Hip__no_passphrase_index_1337() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "",
            index: 1337,
            expectedPrivateKey: "42dfdc74e4b2d0b1c17dde81a538b1be314ebb11e6ca68b01f0cc1328b3c686a",
            expectedAddress: "JGjNMpeo3G8gson65QhEs7sQ4nYgCbfDRtQbUwpmA1eBs39rAL4"
        )
    }
    
    // MARK: Passhrases
    func test_mainnet__Motion_Hip__passphrase_foobar_index_0() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "foobar",
            index: 0,
            expectedPrivateKey: "0b3237496d654b0cc27a9cf2fbad011a58aac40e3dc8312a1a10aa641297d938",
            expectedAddress: "JFryJk3f9c2igEUGVVxTMuAGnNJq98eRyB8Q74gPPdkoQ9qd6JD")
    }
    
    func test_mainnet__Motion_Hip__passphrase_foobar_index_1() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "foobar",
            index: 1,
            expectedPrivateKey: "325fed46473e394bbce41f4dc70f9676eb632f284d2cf4c7b4f5ac520cc7ef92",
            expectedAddress: "JHxRyEZHfF7v9KqFqGD8yGRhq8g88bTFB81X4QffXZhQmgW2eE4"
        )
    }
    
    func test_mainnet__Motion_Hip__passphrase_foobar_index_1337() {
        doTest(
            mnemonic: "motion clever argue fever suffer point energy alpha target quality engine hip",
            passphrase: "foobar",
            index: 1337,
            expectedPrivateKey: "9ffb4b44ee6acb2b8d339a0c69564206780a68b25a78c3e0e0ec9aee4706cb91",
            expectedAddress: "JHNyuVuiH4Qdtzghc4UmsFEirCi3kNsPmTDNywaZ9eo7AVSAKo5"
        )
    }
    
    
    // MARK: - GOWN... TENNIS
    func test_mainnet__Gown_Tennis__no_passphrase_index_0() {
        doTest(
            mnemonic: "gown pulp squeeze squeeze chuckle glance skill glare force dog absurd tennis",
            passphrase: "",
            index: 0,
            expectedPrivateKey: "d4ab3ef327b48a8ac3fe284958111ec5e967df755fef51c3cdbd46986ec15ef8",
            network: .mainnetBTC,
            expectedAddress: "JG5fHyFKCHJCHGTQRXUkM8XMwFouhooYvPR8zitxf1BqGfEXxQ2")
    }
    
    func test_mainnet__Gown_Tennis__no_passphrase_index_237() {
        doTest(
            mnemonic: "gown pulp squeeze squeeze chuckle glance skill glare force dog absurd tennis",
            passphrase: "Lorem ipsum dolor sit amet",
            index: 237,
            expectedPrivateKey: "1ef53329cadeee337442aa0b1caa7f17bbd90a5b91605ee2e59829d7e8bea97a",
            network: .mainnetBTC,
            expectedAddress: "JGonZ6hHZBwZZkeHzf4XAr17R42WdW1Zn11wwW839rzxKW2NAkn")
    }
 
}

private extension PrivateKeyTests {
    func doTest(
        mnemonic mnemonicString: String,
        passphrase: String = "",
        index: Int = 0,
        expectedPrivateKey: String,
        network: BitcoinKit.Network = .mainnetBTC,
        expectedAddress: String
    ) {
        
        let mnemonicWords = mnemonicString.split(separator: " ").map { String($0) }
        
        let seed = BitcoinKit.Mnemonic.seed(mnemonic: mnemonicWords, passphrase: passphrase) { _ in }
        
        let wallet = BitcoinKit.HDWallet(seed: seed, network: network)
        
        let privateKeyBicoinKit = try! wallet.privateKey(index: UInt32(index))
        
        let privateKey = try! PrivateKey(data: privateKeyBicoinKit.data)
        
        XCTAssertEqual(privateKey.hex, expectedPrivateKey)
        
        
        let publicKey = PublicKey(private: privateKey)
        
        let magic: Magic = -1332248574
        let address = Address(
            magic: magic,
            publicKey: publicKey
        )
        XCTAssertEqual(address.full, expectedAddress)
        
    }
}
