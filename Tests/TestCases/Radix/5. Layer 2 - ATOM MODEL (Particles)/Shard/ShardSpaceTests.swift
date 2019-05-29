//
//  ShardSpaceTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class ShardSpaceTests: XCTestCase {
    
    private let irrelevant: Shard = 3
    
    func testWithinRange() {
        
        XCTAssertNoThrow(
            try ShardSpace(
                range: try ShardRange(
                    lower: -(1 << 20),
                    upper: 1 << 20
                ),
                anchor: irrelevant
            )
        )
    }
    
    func testOutOfRange() {
        
        let badRange = try! ShardRange(
            lower: -(1 << 60),
            upper: 1 << 60
        )
        
        XCTAssertThrowsSpecificError(
            try ShardSpace(range: badRange, anchor: irrelevant),
            ShardSpace.Error.spanOfRangeTooBig(expectedAtMost: ShardSpace.shardChunkRangeSpan, butGot: badRange.span)
        )
        
    }
}
