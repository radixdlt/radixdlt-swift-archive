//
//  HashTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class HashTests: XCTestCase {

    func testSha256Twice() {
        let data = "Hello Radix".toData()
        let hasher = Sha256Hasher()
        let singleHash = hasher.hash(data: data)
        let twice = hasher.hash(data: singleHash)
        let double = Sha256TwiceHasher().hash(data: data)
        XCTAssertEqual(double, twice)
        XCTAssertEqual(singleHash.hex, "374d9dc94c1252acf828cdfb94946cf808cb112aa9760a2e6216c14b4891f934")
        XCTAssertEqual(double.hex, "fd6be8b4b12276857ac1b63594bf38c01327bd6e8ae0eb4b0c6e253563cc8cc7")
    }
}
