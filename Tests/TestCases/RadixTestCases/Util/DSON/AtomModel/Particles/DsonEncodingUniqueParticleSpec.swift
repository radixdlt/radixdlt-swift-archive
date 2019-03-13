//
//  DsonEncodingUniqueParticleSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class DSONEncodingPrimitivesUniqueParticleSpec: QuickSpec {

    override func spec() {
        describe("DSON encoding") {
            describe("UniqueParticle") {
                it("should result in the appropriate data") {
                    let uniqueParticle = UniqueParticle(address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei", uniqueName: "CYON")
                    expect(uniqueParticle.toDSON().base64).to(equal("v2dhZGRyZXNzWCcEAgPKYhmie++7PrG8oBKdVISJu+zKiwO7B6MK39/0eVA7/lJdBFdkbmFtZWRDWU9OanNlcmlhbGl6ZXIaVj3LMmd2ZXJzaW9uGGT/"))
                }
            }
        }
    }
}
