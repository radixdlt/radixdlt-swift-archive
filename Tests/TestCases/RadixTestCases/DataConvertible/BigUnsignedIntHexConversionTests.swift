//
//  BigUnsignedIntHexConversionTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import BigInt
import XCTest

class BigUnsignedIntTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testUint256() {
        let table = [
            "10": "A",
            "100": "64",
            "1000": "3E8",
            "10000": "2710",
            "100000": "186A0",
            "1000000": "F4240",
            "10000000": "989680",
            "100000000": "5F5E100",
            "1000000000": "3B9ACA00",
            ]
        for (key, value) in table {
            let bigInt = BigUnsignedInt(stringLiteral: key)
            XCTAssertEqual(bigInt.toHexString(uppercased: true).stringValue, value)
            XCTAssertEqual(bigInt.asData.toHexString(uppercased: true, mode: .trim).stringValue, value)
            XCTAssertEqual(bigInt.toBase64String().asData.toHexString(uppercased: true, mode: .trim).stringValue, value)
            XCTAssertEqual(bigInt.asData.toBase64String().toHexString(uppercased: true, mode: .trim).stringValue, value)
        }
        
    }
}
