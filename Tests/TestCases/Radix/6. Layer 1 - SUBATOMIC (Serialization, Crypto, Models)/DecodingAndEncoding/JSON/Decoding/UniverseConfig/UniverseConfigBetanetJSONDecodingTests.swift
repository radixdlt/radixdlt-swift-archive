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

class UniverseConfigBetanetJSONDecodingTest: XCTestCase {
    
//    private var betanet: UniverseConfig?
//    private var localnet: UniverseConfig?
    
    /*  Run Before Each Test */
    override func setUp() {
        super.setUp()
        
//        betanet = configWithName("betanet")
//        localnet = configWithName("localnet")
    }
    
//    func testUniverses() {
//        func doTest(config: UniverseConfig?, expectedUniverseConfigHashId: HashEUID) {
//            guard let config = config else {
//                return XCTFail("Config was nil")
//            }
//            // Waiting on bug fix for Jackson: https://github.com/cbor/cbor.github.io/issues/49
//            // The Java lib produces incorrect hashEUID for any data containing a Message particle
//            // which serializer `"radix.particles.message"` gets incorrectly CBOR encoded.
//
//            guard let hashIdFromApi = config.hashIdFromApi else { return XCTFail("should have hashId") }
//
//            XCTAssertAllEqual(
//                config.hashEUID,
//                hashIdFromApi,
//                expectedUniverseConfigHashId
//            )
//
//
//            guard let rriParticle = config.genesis.particles().compactMap({ $0 as? ResourceIdentifierParticle }).first else {
//                return XCTFail("No RRI particle")
//            }
//            XCTAssertEqual(rriParticle.resourceIdentifier.name, "XRD")
//
//        }
//
//        doTest(config: betanet, expectedUniverseConfigHashId: "e5e1315128b3f81fcee080b3b404a77c")
//        doTest(config: localnet, expectedUniverseConfigHashId: "21b265b596d4434b269a02018ecc7aec")
//    }
    
    func testAtomAid() {
        guard let atom = decodeOrFail(jsonString: json, to: Atom.self) else { return }

        XCTAssertEqual(try! atom.shards(), [-5634836225579692379, -2214955473087480270])
        XCTAssertEqual(
            try! atom.toDSON(output: DSONOutput.hash).hex, "bf686d65746144617461bf68706f774e6f6e636564333736386974696d657374616d706d31353632363031303839393635ff6e7061727469636c6547726f75707381bf697061727469636c657381bf687061727469636c65bf656279746573581c0148657920426f622c207468697320697320706c61696e20746578746c64657374696e6174696f6e73825102b1cd0a4eb6d1cea5eb288fb4474ac4035102e142e5bb89503e3210b1f2c893eb5c126466726f6d582704020279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798404d542d686d65746144617461bf6b6170706c69636174696f6e676d657373616765ff656e6f6e63653b005c7a1493eb24756a73657269616c697a65727772616469782e7061727469636c65732e6d65737361676562746f5827040202c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee57f51ade76776657273696f6e1864ff6a73657269616c697a65727372616469782e7370756e5f7061727469636c65647370696e016776657273696f6e1864ff6a73657269616c697a65727472616469782e7061727469636c655f67726f75706776657273696f6e1864ff6a73657269616c697a65726a72616469782e61746f6d6776657273696f6e1864ff"
        )
        
        XCTAssertEqual("126fd230a7cab9d9766f1065d498c4ac80ad2b754af1889fdafeb316d52c54e0", atom.radixHash.hex)
        XCTAssertEqual(atom.identifier(), "126fd230a7cab9d9766f1065d498c4ac80ad2b754af1889fb1cd0a4eb6d1cea5")
    }
 
//    func testMessageParticle() {
//        doTest(expectedHashId: "e84075aae7629f002f69bd2fc02d19f1", particleType: MessageParticle.self) {
//            """
//            {
//                "bytes": ":byt:UmFkaXguLi4ganVzdCBpbWFnaW5lIQ==",
//                "destinations": [
//                    ":uid:56abab3870585f04d015d55adf600bc7"
//                ],
//                "serializer": "radix.particles.message",
//                "from": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
//                "to": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
//                "version": 100,
//                "nonce": 1011792898924806
//            }
//            """
//        }
//    }
//
//    func testRriParticle() {
//        doTest(expectedHashId: "ce31e1c05ff5b8f09cdd7ea23b9ba0c1", particleType: ResourceIdentifierParticle.self) {
//            """
//            {
//                "destinations": [
//                    ":uid:56abab3870585f04d015d55adf600bc7"
//                ],
//                "rri": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD",
//                "serializer": "radix.particles.rri",
//                "version": 100,
//                "nonce": 0
//            }
//            """
//        }
//    }
//
//    func testTokenDefinitionParticle() {
//        doTest(expectedHashId: "eca1b185226c606815f534ced6b2c704", particleType: TokenDefinitionParticle.self) {
//            """
//            {
//                "symbol": ":str:XRD",
//                "address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
//                "granularity": ":u20:1",
//                "permissions": {
//                    "burn": ":str:none",
//                    "mint": ":str:token_creation_only"
//                },
//                "destinations": [
//                    ":uid:56abab3870585f04d015d55adf600bc7"
//                ],
//                "name": ":str:Rads",
//                "serializer": "radix.particles.token_definition",
//                "description": ":str:Radix Native Tokens",
//                "iconUrl": ":str:https://assets.radixdlt.com/icons/icon-xrd-32x32.png",
//                "version": 100
//            }
//            """
//        }
//    }

    
    private func doTest<P>(expectedHashId: ParticleHashId, particleType: P.Type, from json: () -> String) where P: ParticleConvertible & RadixModelTypeStaticSpecifying {
        guard let particle = decodeOrFail(jsonString: json(), to: P.self) else { return }
        XCTAssertEqual(particle.hashEUID, expectedHashId)
    }
}

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

private let json = """
{
    "metaData": {
        "powNonce": ":str:3768",
        "timestamp": ":str:1562601089965"
    },
    "particleGroups": [
        {
	        "particles": [
		        {
			        "particle": {
				        "bytes": ":byt:SGV5IEJvYiwgdGhpcyBpcyBwbGFpbiB0ZXh0",
				        "destinations": [
					        ":uid:b1cd0a4eb6d1cea5eb288fb4474ac403",
					        ":uid:e142e5bb89503e3210b1f2c893eb5c12"
				        ],
				        "from": ":adr:JF5FTU5wdsKNp4qcuFJ1aD9enPQMocJLCqvHE2ZPDjUNag8MKun",
				        "metaData": {
					        "application": ":str:message"
				        },
				        "nonce": -26029926656975990,
				        "serializer": "radix.particles.message",
				        "to": ":adr:JFeqmatdMyjxNce38w3pEfDeJ9CV6NCkygDt3kXtivHLsP3p846",
				        "version": 100
			        },
			        "serializer": "radix.spun_particle",
			        "spin": 1,
			        "version": 100
		        }
	        ],
	        "serializer": "radix.particle_group",
	        "version": 100
        }
    ],
    "serializer": "radix.atom",
    "signatures": {
        "b1cd0a4eb6d1cea5eb288fb4474ac403": {
	        "r": ":byt:hz2eTf+dfg+upz9fBm1xj4xWZLachodJgGWXjWEB0XY=",
	        "s": ":byt:OkeqfpgOytiNnDL5CqNN9xy9LS66c7+TSRFiwgt/DtM=",
	        "serializer": "crypto.ecdsa_signature",
	        "version": 100
        }
    },
    "version": 100
}
"""
