//
//  AtomJsonSerializationTwoParticleGroupsSpec.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

extension JSONEncoder {
    convenience init(outputFormat: JSONEncoder.OutputFormatting) {
        self.init()
        self.outputFormatting = outputFormat
    }
}

class AtomJsonSerializationTwoParticleGroupsSpec: QuickSpec {
    
    override func spec() {
        /// Scenario 2
        /// https://radixdlt.atlassian.net/browse/RLAU-943
        describe("JSON serialization - Two ParticleGroups each containing one particle") {
            it("should result in the appropriate non trivial JSON") {
                do {
                    let json = try JSONEncoder(outputFormat: .prettyPrinted).encode(atom)
                    let jsonString = String(data: json, encoding: .utf8)!
                    let atomFromJSON = try JSONDecoder().decode(Atom.self, from: jsonString.data(using: .utf8)!)
                    expect(atomFromJSON).to(equal(atom))
                } catch let encodingError as EncodingError {
                    fail("unexpected EncodingError: \(encodingError)")
                } catch let decodingError as DecodingError {
                    fail("unexpected DecodingError: \(decodingError)")
                } catch {
                    fail("unexpected error")
                }
            }
        }
        
    }
}
private let atom = Atom(
    particleGroups: [
        ParticleGroup(spunParticles: [
            SpunParticle(
                spin: .up,
                particle: TokenDefinitionParticle(
                    symbol: "CCC",
                    name: "Cyon",
                    description: "Cyon Crypto Coin is the worst shit coin",
                    address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
                    metaData: [
                        .timestamp: "1551345320000",
                        "foo": "bar"
                    ],
                    granularity: 1,
                    permissions: .allPow
                )
            ),
            SpunParticle(
                spin: .up,
                particle: TokenParticle(
                    type: .mintedToken,
                    owner: "A3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9o",
                    receiver: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                    nonce: 992284943125945,
                    planck: 24805440,
                    amount: 1337,
                    tokenDefinitionIdentifier: "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD"
                )
            )
            ])
    ],
    signatures: [
        "71c3c2fc9fee73b13cad082800a6d0de": try! Signature(
            r: Signature.Part(base64: "JRULGkmWzxVx0AtO8NYmZ0Aqbi6hG/Vj6GeoB3TvHAX="),
            s: Signature.Part(base64: "KbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9H=")
        )
    ],
    metaData: [
        .timestamp: "1551345320000"
    ]
)
