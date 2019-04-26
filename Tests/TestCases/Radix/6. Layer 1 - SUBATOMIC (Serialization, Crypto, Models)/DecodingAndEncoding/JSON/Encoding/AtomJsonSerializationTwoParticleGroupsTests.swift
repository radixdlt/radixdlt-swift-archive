//
//  AtomJsonSerializationTwoParticleGroupsTests.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
        ParticleGroup(spunParticles: [
            AnySpunParticle(
                spin: .up,
                particle: TokenDefinitionParticle(
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
                    uniqueName: "Sajjon"
                )
            )
        ])
    ]
)
