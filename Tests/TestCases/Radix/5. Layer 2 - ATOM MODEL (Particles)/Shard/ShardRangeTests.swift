//
//  ShardRangeTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//


import XCTest
@testable import RadixSDK

class ShardRangeTests: XCTestCase {
    
    func testOkRange() {
        XCTAssertNoThrow(
            try ShardRange(
                lower: 1,
                upper: 3
            )
        )
    }
    
    func testOutOfRange() {
        XCTAssertThrowsSpecificError(
            try ShardRange(
                lower: 3,
                upper: 1
            ),
            ShardRange.Error.upperMustBeGreaterThanLower
        )
    }
    
    func testSpan() {
        func doTest(lower: Shard, upper: Shard, expectedStride: Shard) {
            do {
                let range = try ShardRange(lower: lower, upper: upper)
                XCTAssertEqual(range.stride, expectedStride)
            } catch {
                XCTFail("bad range")
            }
        }
        doTest(lower: 0, upper: 1, expectedStride: 1)
        doTest(lower: 0, upper: 2, expectedStride: 2)
        doTest(lower: 1, upper: 5, expectedStride: 4)
    }
}
