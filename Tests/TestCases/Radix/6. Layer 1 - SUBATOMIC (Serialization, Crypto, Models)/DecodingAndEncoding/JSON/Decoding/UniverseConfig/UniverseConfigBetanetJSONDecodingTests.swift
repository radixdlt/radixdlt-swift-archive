//
//  UniverseConfigBetanetJSONDecodingTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class UniverseConfigBetanetJSONDecodingTest: XCTestCase {
    
    private var betanet: UniverseConfig?
    private var localnet: UniverseConfig?
    
    /*  Run Before Each Test */
    override func setUp() {
        super.setUp()
        
        betanet = configWithName("betanet")
        localnet = configWithName("localnet")
    }
    
    func testUniverses() {
        func doTest(config: UniverseConfig?) {
            guard let config = config else {
                return XCTFail("Config was nil")
            }
            // Waiting on bug fix for Jackson: https://github.com/cbor/cbor.github.io/issues/49
            // The Java lib produces incorrect hashEUID for any data containing a Message particle
            // which serializer `"radix.particles.message"` gets incorrectly CBOR encoded.
            //        if let hashIdFromApi = config.hashIdFromApi {
            //            XCTAssertEqual(config.hashEUID, hashIdFromApi)
            //        }
            
            guard let rriParticle = config.genesis.particles().compactMap({ $0 as? ResourceIdentifierParticle }).first else {
                return XCTFail("No RRI particle")
            }
            XCTAssertEqual(rriParticle.resourceIdentifier.name, "XRD")
            
        }
        
        doTest(config: betanet)
        doTest(config: localnet)
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
