//
//  GranularityTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class GranularityTests: XCTestCase {
    
    func testThatCannotCreateZeroGranularity() {
        XCTAssertThrowsSpecificError(try Granularity(int: 0), Granularity.Error.cannotBeZero)
    }
    
    func testAssertTooLargeThrowsError() {
        
        let expectedError: Granularity.Error = .tooLarge(expectedAtMost: Granularity.subunitsDenominator, butGot: Granularity.subunitsDenominator + 1)
        
        XCTAssertThrowsSpecificError(
            try Granularity(value: Granularity.subunitsDenominator + 1),
            expectedError
        )
    }
    
    func testGranularityToHex() {
        // GIVEN
        // A Granularity of 1
        let granularityOfOne: Granularity = 1
        
        // WHEN
        // I convert it into hex
        let granularityOfOneAsHex = granularityOfOne.hex
        
        // THEN
        // Its length is 64
        XCTAssertEqual(
            granularityOfOneAsHex.count,
            64,
            "Encoding must be 64 chars long"
        )
        // and is value is 1 with 63 leading zeros
        XCTAssertEqual(
            granularityOfOneAsHex,
            "0000000000000000000000000000000000000000000000000000000000000001"
        )
    }
    
    func testDsonEncodeGranularityOfOne() {
        // GIVEN
        // A Granularity of 1
        let granularityOfOne: Granularity = 1
        // WHEN
        // I DSON encode that
        guard let dsonHex = dsonHexStringOrFail(granularityOfOne) else { return }
        
        // THEN
        // I get the same results as Java lib
        XCTAssertEqual(
            dsonHex,
            "5821050000000000000000000000000000000000000000000000000000000000000001"
        )
    }
    
    func testDsonEncodeGranularityBig() {
        // GIVEN
        // A big granularity
        let granularity: Granularity = "10000000000000"
        // WHEN
        // I DSON encode that
        guard let dsonHex = dsonHexStringOrFail(granularity) else { return }
        
        // THEN
        // I get the same results as Java lib
        XCTAssertEqual(
            dsonHex,
            "582105000000000000000000000000000000000000000000000000000009184e72a000"
        )
    }
}
