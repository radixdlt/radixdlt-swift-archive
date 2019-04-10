//
//  ProofOfWorkTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class ProofOfWorkTest: XCTestCase {
    
    func testPowSingleLeadingZero() {
        let magic: Magic = 1
        let seed = Data(repeating: 0x00, count: 32)
        do {
            let pow = try ProofOfWork.work(seed: seed.asData, magic: magic, numberOfLeadingZeros: 1)
            try pow.prove()
            XCTAssertEqual(pow.nonceAsString, "5")
        } catch {
            XCTFail("POW fail, error: \(error)")
            
        }
    }
    
    func test4LeadingZerosDeadbeefSeed() {
        let magic: Magic = 12345
        let seed: HexString = "deadbeef00000000deadbeef00000000deadbeef00000000deadbeef00000000"
        do {
            let pow = try ProofOfWork.work(seed: seed.asData, magic: magic, numberOfLeadingZeros: 4)
            try pow.prove()
            XCTAssertEqual(pow.nonceAsString, "30")
        } catch {
            XCTFail("POW fail, error: \(error)")
            
        }
    }
}
