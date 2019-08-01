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

class ECIESDecryptMessageTests: XCTestCase {
    
    /// This message was pasted into the Java library to ensure that the Java library can decrypt messages encrypted by this Swift library
    /// this is important because byte order seems to differ for integers (length of cipherText encoded as 4 bytes seems to differ.)
    func testEncryptThenDecrypt() {
        
        // GIVEN
        // An a message encrypted using private key `1`
        let encryptedByThisLibrary: HexString = "51358bd242d0436b738dad123ebf1d8b2103ca9978dbb11cb9764e0bcae41504b4521f0290ac0f33fa659528549d9ce84d230000003096dc6785ea0dec1ac1ae15374e327635115407f9ae268aad8b4b6ebae1afefbc83c5792de6fc3550d3e0383918d182e87876c9c0e3b5ca0c960fd95b4bd18421ead2aaf472012e7cfbfd7b314cbae588"
        
        // WHEN
        // We try to decrypt the encrypted message using the same key
        guard let decrypted = XCTAssertNotThrows(
            try KeyPair(private: 1).decryptAndDecode(encryptedByThisLibrary)
        ) else { return }
        
        
        // THEN
        // We should retrive the orignal message
        XCTAssertEqual("Hello Java Library from Radix Swift Library!", decrypted)
    }
}
