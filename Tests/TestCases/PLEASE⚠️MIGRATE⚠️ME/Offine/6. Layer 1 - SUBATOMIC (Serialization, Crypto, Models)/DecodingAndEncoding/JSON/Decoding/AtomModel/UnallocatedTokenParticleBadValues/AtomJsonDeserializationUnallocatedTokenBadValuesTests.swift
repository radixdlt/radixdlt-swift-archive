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

class AtomJsonDeserializationUnallocatedTokenBadValuesTests: AtomJsonDeserializationChangeJson {
        
    override func jsonString() -> String {
        return """
            {
                "\(RadixModelType.jsonKey)": "\(RadixModelType.atom.serializerId)",
                "signatures": {},
                "metaData": {
                    "timestamp": ":str:1488326400000"
                },
                "particleGroups": [
                    {
                        "\(RadixModelType.jsonKey)": "\(RadixModelType.particleGroup.serializerId)",
                        "particles": [
                            {
                                "\(RadixModelType.jsonKey)": "\(RadixModelType.spunParticle.serializerId)",
                                "spin": 1,
                                "particle": {
                                    "\(RadixModelType.jsonKey)": "\(RadixModelType.unallocatedTokensParticle.serializerId)",
                                    "granularity": ":u20:1",
                                    "nonce": 992284943125945,
                                    "permissions": {
                                        "mint": ":str:token_owner_only",
                                        "burn": ":str:none"
                                    },
                                    "amount": ":u20:100000",
                                    "tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnkntokens/XRD"
                                }
                            }
                        ],
                        "metaData": {}
                    }
                ]
            }
        """
    }
}
