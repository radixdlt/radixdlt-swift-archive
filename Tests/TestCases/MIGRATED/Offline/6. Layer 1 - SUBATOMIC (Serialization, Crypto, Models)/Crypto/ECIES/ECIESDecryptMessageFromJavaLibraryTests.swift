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
import XCTest
@testable import RadixSDK

class ECIESDecryptMessageFromJavaLibraryTests: XCTestCase {
    func testDecryptMessage() {
        // GIVEN
        // The message "Hello Radix", ECIES encrypted by the Java library using the PrivateKey: 1
        let encryptedByJava: HexString = "000102030405060708090a0b0c0d0e0f21036d6caac248af96f6afa7f904f550253a0f3ef3f5aa2fe6838a95b216691468e200000010360c3d2fd2eaa6049304361a5dda90728857e21cedd2de6496ddb0174557acb8eaf9ed02c24633a3e9165b3f2d1406b2"
        
        // WHEN
        // I decrypt it
        guard let decrypted = XCTAssertNotThrows(
            try KeyPair(private: 1).decryptAndDecode(encryptedByJava)
        ) else { return }
        
        // THEN
        // I can read out the original message
        XCTAssertEqual("Hello Radix", decrypted)
    }
}
