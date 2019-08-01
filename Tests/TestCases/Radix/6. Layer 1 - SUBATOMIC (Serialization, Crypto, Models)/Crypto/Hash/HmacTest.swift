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

import Foundation
import XCTest
@testable import RadixSDK

class ECIESHmacCalculationTests: XCTestCase {
    
    func testHmacCalc() {
        let bytes16: HexString = "1234567890ABCDEF1234567890ABCDEF"
        
        guard let bytes32 = XCTAssertNotThrows(
            try HexString(hexString: bytes16.stringValue + bytes16.stringValue)
        ) else { return }
        
        guard let privateKey = XCTAssertNotThrows(
             try PrivateKey(hex: bytes32)
        ) else { return }
        
        let keyPair = KeyPair(private: privateKey)
        let publicKey = keyPair.publicKey
        
        XCTAssertEqual(
            publicKey.hex,
            "02bb50e2d89a4ed70663d080659fe0ad4b9bc3e06c17a227433966cb59ceee020d",
            "It should work like the Java library"
        )
        
        let keyM = bytes32
        let iv = bytes16
        let cipherText = "A super duper mega secret string"
        let cipherTextEncoded = cipherText.toData()
        XCTAssertEqual(cipherText.length, 32)
        
        guard let mac = XCTAssertNotThrows(
            try ECIES.calculateMAC(salt: keyM, initializationVector: iv, ephemeralPublicKey: publicKey, cipherText: cipherTextEncoded)
        ) else { return }
        
        XCTAssertEqual(
            mac.hex,
            "277ec636418da1504cccffcc699d7f95b5ee3ec09e425494460f7f21139fb74a",
            "It should work like the Java library"
        )
    }
    
}
