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

@testable import RadixSDK
import XCTest

class AtomWithTrivialMetaDataDsonEncodingTests: XCTestCase {
    
    func testDsonOfAtomFromJsonMatchesJavaLibrary() {
        // GIVEN
        // A simple atom
        let jsonString = jsonStringAtomWithJustMetaData
        guard let atomFromJson = decodeOrFail(jsonString: jsonString, to: Atom.self) else { return }
        
        // WHEN
        // I DSON encode it
        guard let dson = dsonOrFail(atomFromJson) else { return }
        
        // THEN
        XCTAssertEqual(dson.hex, expectedDsonHex, "DSON hex matches Java library")
        XCTAssertEqual(dson.base64, expectedDsonBase64, "DSON base64 matches Java library")
        
    }
    
    func testDsonOfAtomInCodeMatchesJavaLibrary() {
        // GIVEN
        // A simple atom
        let atom = Atom(metaData: .timestamp("1488326400000"))
        
        // WHEN
        // I DSON encode it
        guard let dson = dsonOrFail(atom) else { return }
        
        // THEN
        XCTAssertEqual(dson.hex, expectedDsonHex, "DSON hex matches Java library")
        XCTAssertEqual(dson.base64, expectedDsonBase64, "DSON base64 matches Java library")
        
    }
    
    func testThatHashIdMatchesJavaLibrary() {
        // GIVEN
        // A simple atom
        let atom = Atom(metaData: .timestamp("1488326400000"))
        
        // WHEN
        // I calculate the Radix Hash
        let radixHash = atom.radixHash
        
        // THEN
        XCTAssertEqual(
            radixHash,
            "14bc51478733cb75ffc4bbd85e392bde450ebdcbed102090deb10154a90a0239",
            "Radix hash matches Java library"
        )
    }
}

private let expectedDsonHex = "bf686d65746144617461bf6974696d657374616d706d31343838333236343030303030ff6a73657269616c697a65726a72616469782e61746f6d6776657273696f6e1864ff"

private let expectedDsonBase64 = "v2htZXRhRGF0Yb9pdGltZXN0YW1wbTE0ODgzMjY0MDAwMDD/anNlcmlhbGl6ZXJqcmFkaXguYXRvbWd2ZXJzaW9uGGT/"

private let jsonStringAtomWithJustMetaData = """
{
    "serializer": "\(RadixModelType.atom.serializerId)",
    "\(jsonKeyVersion)": \(serializerVersion),
    "metaData": {
        "timestamp": ":str:1488326400000"
    }
}
"""


public struct SkipHashing: Hashing {
    public init() {}
    public func hash(data: Data) -> Data {
        return data
    }
}
