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

class UniverseConfigBetanetJSONDecodingTest: XCTestCase {
    
    func testLocalnetConfigHashIdMatchesBundled() {
        let config: UniverseConfig = .localnet
        XCTAssertEqual(
            config.hashIdFromApi,
            config.hashEUID
        )
    }

    func testMessageParticle() {
        doTest(expectedHashId: "d976d16a3058930eb72d8c8f4115e343", particleType: MessageParticle.self) {
            """
            {
                "bytes": ":byt:UmFkaXguLi4ganVzdCBpbWFnaW5lIQ==",
                "destinations": [
                    ":uid:56abab3870585f04d015d55adf600bc7"
                ],
                "serializer": "radix.particles.message",
                "from": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                "to": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                "version": 100,
                "nonce": 982125088533081
            }
            """
        }
    }

    func testRriParticle() {
        doTest(expectedHashId: "ce31e1c05ff5b8f09cdd7ea23b9ba0c1", particleType: ResourceIdentifierParticle.self) {
            """
            {
                "destinations": [
                    ":uid:56abab3870585f04d015d55adf600bc7"
                ],
                "rri": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD",
                "serializer": "radix.particles.rri",
                "version": 100,
                "nonce": 0
            }
            """
        }
    }

    func testTokenDefinitionParticle() {
        doTest(expectedHashId: "9ba72f1e2867aaf9c6e63cd553396ea2", particleType: FixedSupplyTokenDefinitionParticle.self) {
            """
            {
                "granularity": ":u20:1",
                "destinations": [
                    ":uid:56abab3870585f04d015d55adf600bc7"
                ],
                "rri": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD",
                "name": ":str:Rads",
                "serializer": "radix.particles.fixed_supply_token_definition",
                "description": ":str:Radix Native Tokens",
                "iconUrl": ":str:https://assets.radixdlt.com/icons/icon-xrd-32x32.png",
                "version": 100,
                "supply": ":u20:1000000000000000000000000000"
            }
            """
        }
    }
    
    func testTransferrableTokensParticle() {
        doTest(expectedHashId: "9ff7ae92fe061ee065ddbf6ef04ea966", particleType: TransferrableTokensParticle.self) {
             """
             {
                 "amount": ":u20:1000000000000000000000000000",
                 "address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                 "granularity": ":u20:1",
                 "destinations": [
                     ":uid:56abab3870585f04d015d55adf600bc7"
                 ],
                 "serializer": "radix.particles.transferrable_tokens",
                 "version": 100,
                 "nonce": 982125088539821,
                 "tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD",
                 "planck": 25853760
             }
             """
         }
    }
    
    private func doTest<P>(expectedHashId: ParticleHashId, particleType: P.Type, from json: () -> String) where P: ParticleConvertible & RadixModelTypeStaticSpecifying {
        guard let particle = decodeOrFail(jsonString: json(), to: P.self) else { return }
        XCTAssertEqual(particle.hashEUID, expectedHashId)
    }
}

typealias ParticleHashId = HashEUID

private extension UniverseConfigBetanetJSONDecodingTest {
    
    func configWithName(_ nameOfConfig: String) -> UniverseConfig? {
        guard let jsonFileUrl = self.testBundle.url(forResource: nameOfConfig, withExtension: "json") else {
            return nil
        }
        
        guard let data = XCTAssertNotThrows(
            try Data(contentsOf: jsonFileUrl)
        ) else { return nil }
        
        guard let config = decodeOrFail(jsonData: data, to: UniverseConfig.self) else { return nil }
        return config
    }
}
