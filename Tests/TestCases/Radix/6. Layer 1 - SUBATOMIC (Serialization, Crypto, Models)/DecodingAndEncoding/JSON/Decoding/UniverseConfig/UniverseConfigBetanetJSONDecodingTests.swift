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
    func testUniverses() {
        test(config: "betanet")
        //       test(config: "sunstone")
    }
    
    private func test(config: String) {
        guard let jsonFileUrl = self.testBundle.url(forResource: config, withExtension: "json") else {
            return XCTFail("file not found")
        }
        
        guard let data = XCTAssertNotThrows(
            try Data(contentsOf: jsonFileUrl)
        ) else { return }
        
        //                    let config = try JSONDecoder().decode(UniverseConfig.self, from: data)
        guard let config = decodeOrFail(jsonData: data, to: UniverseConfig.self) else { return }
        
        // Waiting on bug fix for Jackson: https://github.com/cbor/cbor.github.io/issues/49
        // The Java lib produces incorrect hashId for any data containing a Message particle
        // which serializer `"radix.particles.message"` gets incorrectly CBOR encoded.
        
        //                    guard let hashIdFromApiUsedForTesting = config.hashIdFromApiUsedForTesting else {
        //                        return
        //                    }
        
        guard let rriParticle = config.genesis.particles().compactMap({ $0 as? ResourceIdentifierParticle }).first else {
            return XCTFail("No RRI particle")
        }
        XCTAssertEqual(rriParticle.resourceIdentifier.name, "XRD")
        
    }
}
