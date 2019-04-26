//
//  CBOREncodingPrimitivesBoolTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-07.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class CBOREncodingPrimitivesBoolTests: XCTestCase {

    func testCborEncodingBoolFalse() {
        XCTAssertEqual(
            false.cborEncodedHexString(),
            "f4"
        )
    }
    
    func testCborEncodingBoolTrue() {
        XCTAssertEqual(
            true.cborEncodedHexString(),
            "f5"
        )
    }
}

extension DSONEncodable {
    func cborEncodedHexString() -> String {
        return try! toDSON(output: .all).hex
    }
}
