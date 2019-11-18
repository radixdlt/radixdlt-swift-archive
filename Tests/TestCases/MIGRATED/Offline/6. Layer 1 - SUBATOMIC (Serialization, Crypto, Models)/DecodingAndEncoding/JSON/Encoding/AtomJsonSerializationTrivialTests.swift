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

class AtomJsonSerializationTrivialTests: TestCase {
    
    func testJsonEncodingAndDecodingResultsInTheSameTrivialAtom() {

        // GIVEN
        // A simple atom
        let atom: Atom = [
            try! UniqueParticle(
                address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
                string: "Sajjon"
            ).withSpin(.up).wrapInGroup()
        ]
        
        // WHEN
        // I JSON encode said Atom
        guard let jsonString = jsonStringOrFail(atom) else { return }
        // and JSON decode said JSON into an Atom again
        guard let atomFromJson = decodeOrFail(jsonString: jsonString, to: Atom.self) else { return}
        
        // THEN
        // The two atoms equals each other
        XCTAssertEqual(atomFromJson, atom)
        
    }
}
