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

import XCTest
@testable import RadixSDK

class SignatureLengthTests: XCTestCase {

    
    func testLengthOfSignatureIs64BytesEvenForLowValueR() {
        
        // Some randomly generated key
        let privateKey: PrivateKey = "e89cd673f248f5a7d8133d48cc5c47a85c3ff0019367f6f23440c448ca35260c"
        
        // UTF8 encoding of some randomly generated UUID string...
        let unhashedDataHex: HexString = "3833323861653832383165383465396538656461313432636130646363623761"
        let unhashedData = unhashedDataHex.asData
        let hashedData = Sha256Hasher().sha256(of: unhashedData)
        XCTAssertEqual(hashedData.hex, "8ba38dc358bb67bdaa3088e996efb9c328bfcf08792aaf22a8875dea7c2ea951")

        do {
            let signature = try Signer.sign(hashedData: hashedData, privateKey: privateKey)

            // low value R
            XCTAssertEqual(signature.r.hex, "13d7afea1697736ef7dac7cc36ccf0adfcf5f82a4edca2bbd361432f276999")

            XCTAssertEqual(signature.s.hex, "23e9a12e7e84eedf8a94be076b9fb0f7bfcc9eab3303c74e0a1c3ecc439d2ef9")
            
            // The relevant part is that we should see two leading zeros, ensuring the length of the signature is indeed 64 bytes.
            XCTAssertEqual(signature.asData.hex, "0013d7afea1697736ef7dac7cc36ccf0adfcf5f82a4edca2bbd361432f27699923e9a12e7e84eedf8a94be076b9fb0f7bfcc9eab3303c74e0a1c3ecc439d2ef9")
        } catch {
            XCTFail("Signing failed, privateKey: \(privateKey), unhashedData: \(unhashedData.hex), error: \(error), hashedData: \(hashedData.hex)")
        }
    }
}
