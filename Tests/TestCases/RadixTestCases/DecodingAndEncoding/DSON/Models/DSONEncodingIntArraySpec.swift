//
//  DSONEncodingIntArraySpec.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import Nimble
import Quick

class DSONEncodingIntArraySpec: QuickSpec {
    
    override func spec() {
        describe("DSON encoding") {
            describe("Array") {
                let intArray: [Int] = [1, 2, 3, 4]
                let cbor = CBOR.array(intArray.map { CBOR(integerLiteral: $0) }).encode()
                let dson = try! intArray.toDSON(output: .all)
                
                it("should start with `0b100` and number of items") {
                    expect(cbor.hex).to(equal("8401020304"))
                    expect(dson.hex).to(equal(cbor.hex))
                }
            }
        }
    }
}
