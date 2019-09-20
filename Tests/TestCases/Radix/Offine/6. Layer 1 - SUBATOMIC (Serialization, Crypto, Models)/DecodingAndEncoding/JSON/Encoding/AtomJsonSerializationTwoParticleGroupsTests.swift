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

class AtomJsonSerializationTwoParticleGroupsTests: XCTestCase {
    
    func testJsonEncodingOfAtomWithTwoParticleGroups() {
        guard let jsonString = jsonStringOrFail(atom) else { return }
        XCTAssertContains(jsonString, "Sajjon")
        guard let atomFromJson = decodeOrFail(jsonString: jsonString, to: Atom.self) else { return }
        XCTAssertEqual(atomFromJson, atom)
        
    }
}
private let atom = Atom(
    metaData: [
        .timestamp: "1551345320000"
    ],
    signatures: [
        "71c3c2fc9fee73b13cad082800a6d0de": try! Signature(
            r: Signature.Part(base64: "JRULGkmWzxVx0AtO8NYmZ0Aqbi6hG/Vj6GeoB3TvHAX="),
            s: Signature.Part(base64: "KbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9H=")
        )
    ],
    particleGroups: [
        try! ParticleGroup(spunParticles: [
            AnySpunParticle(
                spin: .up,
                particle: try! MutableSupplyTokenDefinitionParticle(
                    symbol: "CCC",
                    name: "Cyon",
                    description: "Cyon Crypto Coin is the worst shit coin",
                    address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
                    granularity: 1,
                    permissions: .all
                )
            ),
            AnySpunParticle(
                spin: .up,
                particle: UnallocatedTokensParticle(
                    amount: 1337,
                    tokenDefinitionReference: "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD"
                )
            ),
            AnySpunParticle(
                spin: .up,
                particle: MessageParticle(
                    from: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                    to: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
                    message: "Hello Radix!"
                )
            ),
            AnySpunParticle(
                spin: .up,
                particle: UniqueParticle(
                    address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
                    string: "Sajjon"
                )
            )
        ])
    ]
)
