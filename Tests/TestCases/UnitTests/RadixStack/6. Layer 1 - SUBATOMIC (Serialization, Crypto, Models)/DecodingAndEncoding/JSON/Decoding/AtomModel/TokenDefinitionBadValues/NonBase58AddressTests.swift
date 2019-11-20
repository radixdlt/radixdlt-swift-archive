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

@testable import RadixSDK
import XCTest

class NonBase58AddressTests: TestCase, AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingInvalidBase58InAddress() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .rri, with: ":rri:/J?????8zD2BMW?????cKAFx1?????UqBSsq?????kkVD7?????a/XRD")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.invalidCharacters(
                expectedCharacterSet: Base58String.allowedCharacters,
                expectedCharacters: Base58String.allowedCharacters.asString,
                butGot: "?"
            ),
            "Decoding should fail to deserialize JSON with address containing '?'"
        )
    }
}
