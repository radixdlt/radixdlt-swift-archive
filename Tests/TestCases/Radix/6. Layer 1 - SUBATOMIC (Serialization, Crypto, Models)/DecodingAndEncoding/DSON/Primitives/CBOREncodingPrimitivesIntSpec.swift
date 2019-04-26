//
//  CBOREncodingPrimitivesIntSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest


class CBOREncodingPrimitivesIntTests: XCTestCase {
    
    func testCBOREncodingPositiveInt() {
        XCTAssertEqual(10.cborEncodedHexString(), "0a")
    }
    
    func testCBOREncodingNegativeInt() {
        XCTAssertEqual(Int(-1).cborEncodedHexString(), "20")
    }
}
