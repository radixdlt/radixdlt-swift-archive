//
//  NumberOfLeadingZeroBitsInDataTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-06-10.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class NumberOfLeadingZeroBitsInDataTests: XCTestCase {

    func testCountNumberOfLeadingZeroBitsInData() {
        func doTest(data: DataConvertible, expectZeroCount: Int) {
            XCTAssertEqual(data.numberOfLeadingZeroBits, expectZeroCount)
        }
        doTest(data: Data(), expectZeroCount: 0)
        doTest(data: [0], expectZeroCount: 8)
        doTest(data: [1], expectZeroCount: 7)
        doTest(data: [255], expectZeroCount: 0)
        doTest(data: [0, 0], expectZeroCount: 16)
        doTest(data: [1, 0], expectZeroCount: 7)
        doTest(data: [0, 0, 0], expectZeroCount: 24)
        doTest(data: [1, 0, 0], expectZeroCount: 7)
        doTest(data: [255, 0, 0], expectZeroCount: 0)
        doTest(data: [0, 1, 0], expectZeroCount: 15)
        doTest(data: [0, 255, 0], expectZeroCount: 8)
        doTest(data: [0, 0, 0, 0], expectZeroCount: 32)
        doTest(data: [0, 0, 1, 0], expectZeroCount: 23)
        doTest(data: [0, 0, 0, 1], expectZeroCount: 31)
    }
}
