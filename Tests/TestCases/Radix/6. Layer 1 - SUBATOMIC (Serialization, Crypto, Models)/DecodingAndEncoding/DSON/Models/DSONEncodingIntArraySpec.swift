//
//  DSONEncodingIntArraySpec.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class DSONEncodingIntArrayTests: XCTestCase {
    
    func testDsonEncodingOfArray() {
        let intArray: [Int] = [1, 2, 3, 4]
        let cbor = CBOR.array(intArray.map { CBOR(integerLiteral: $0) }).encode()
        guard let dsonHex =  dsonHexStringOrFail(intArray, output: .all) else { return }
        XCTAssertAllEqual(cbor.hex, dsonHex, "8401020304")
    }
}
