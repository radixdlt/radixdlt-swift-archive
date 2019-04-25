//
//  UniverseConfigBetanetJSONDecodingTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

extension XCTestCase {
    var testBundle: Bundle {
        return Bundle(for: type(of: self))
    }
}

class UniverseConfigBetanetJSONDecodingTest: QuickSpec {
    override func spec() {
        test(config: "betanet")
        //       test(config: "sunstone")
    }
    
    private func test(config: String) {
        describe("Universe \(config) JSON decoding") {
            it("should decode without problems") {
                guard let jsonFileUrl = self.testBundle.url(forResource: config, withExtension: "json") else {
                    return XCTFail("file not found")
                }
                
                do {
                    let data = try Data(contentsOf: jsonFileUrl)
                    let config = try JSONDecoder().decode(UniverseConfig.self, from: data)
                    
                    // Waiting on bug fix for Jackson: https://github.com/cbor/cbor.github.io/issues/49
                    // The Java lib produces incorrect hashId for any data containing a Message particle
                    // which serializer `"radix.particles.message"` gets incorrectly CBOR encoded.
                    
//                    guard let hashIdFromApiUsedForTesting = config.hashIdFromApiUsedForTesting else {
//                        return
//                    }
//                    expect(config.hashId).to(equal(hashIdFromApiUsedForTesting))
                    expect(config.hashId.hex).to(equal("e5027d7370ee2dbf94b931c35d2e96ce"))
                    guard let rriParticle = config.genesis.particles().compactMap({ $0 as? ResourceIdentifierParticle }).first else {
                        return XCTFail("No RRI particle")
                    }
                    expect(rriParticle.resourceIdentifier.name).to(equal("XRD"))
                } catch {
                    XCTFail("failed to parse file, error: \(error)")
                }
            }
        }
    }
}
