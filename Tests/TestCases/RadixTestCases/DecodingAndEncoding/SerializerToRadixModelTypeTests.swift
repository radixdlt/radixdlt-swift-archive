//
//  SerializerToRadixModelTypeTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class SerializerTests: XCTestCase {
    func testSerializerIds() {
        var tested = Set<RadixModelType>()
        
        func doTest(_ modelType: RadixModelType, _ expected: Int) {
            tested.insert(modelType)
            XCTAssertEqual(modelType.serializerId, expected)
        }
        doTest(.signature, -434788200)
        doTest(.nodeRunnerData, 2451810)
        doTest(.radixSystem, -1833998801)
        doTest(.atom, 2019665)
        doTest(.particleGroup, -67058791)
        doTest(.spunParticle, -993052100)
        doTest(.udpNodeRunnerData, 151517315)
        doTest(.universeConfig, 492321349)
        doTest(.messageParticle, -1254222995)
        doTest(.unallocatedTokensParticle, -1709707314)
        doTest(.tokenDefinitionParticle, -1135093134)
        doTest(.transferrableTokensParticle, 24893441)
        doTest(.uniqueParticle, 1446890290)
        doTest(.atomEvent, -1784097847)
        
        XCTAssertEqual(tested.count, RadixModelType.allCases.count)
    }
}
