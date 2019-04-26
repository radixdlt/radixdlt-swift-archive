//
//  CBOREncodingPrimitivesStringTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class CBOREncodingPrimitivesStringTests: XCTestCase {
    
    func testCborEncodingOfString() {
        XCTAssertEqual(
            "Radix".cborEncodedHexString(),
            "655261646978" // http://cbor.me/
        )
    }
}
