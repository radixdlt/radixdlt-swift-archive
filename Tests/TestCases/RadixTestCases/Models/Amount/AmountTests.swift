//
//  AmountTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class AmountTests: XCTestCase {
    func test256BitMaxValue() {
        XCTAssertEqual(Amount.maxValue256Bits.hex, String(repeating: "f", count: 64))
    }
}
