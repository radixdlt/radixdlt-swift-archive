//
//  DecodePointFromPublicKeyTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class DecodePointTests: XCTestCase {
    func testPointDecoding() {
        do {
            
            let expectedX = "5d21e7a118c479a007d45401bdbd06e3f9814ad5bbbbc5cec17f19029a060903"
            let expectedY = "ccfca71eff2101ad68238112e7585110e0f2c32d345225985356dc7cab8fdcc9"
            
            let privateKeyFromCompressed = try PrivateKey(wif: "L2r8WPXNgQ79rBdyxjdscd5HHr7BaD9P8Xov7NWZ9pVNw12TFSDZ")
            let publicKeyCompressed = PublicKey(private: privateKeyFromCompressed)
            XCTAssertEqual(publicKeyCompressed.hex, "03" + expectedX)
            
            let decodedFromCompressed = EllipticCurvePoint.decodePointFromPublicKey(publicKeyCompressed)
            XCTAssertEqual(decodedFromCompressed.x.hex, expectedX)
            XCTAssertEqual(decodedFromCompressed.y.hex, expectedY)
            
        } catch {
            XCTFail("Error: \(error)")
        }
    }
}
