//
//  DSONEncodingPrimitivesBoolSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-07.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class CBOREncodingPrimitivesBoolSpec: QuickSpec {

    override func spec() {
        describe("DSON encoding") {
            describe("bool = false") {
                it("should result in the appropriate data") {
                    expect(false.cborEncodedHexString()).to(equal("f4"))
                }
            }
            
            describe("bool = true") {
                it("should result in the appropriate data") {
                    expect(true.cborEncodedHexString()).to(equal("f5"))
                }
            }
        }
    }
}

extension DSONEncodable {
    func cborEncodedHexString() -> String {
        return try! toDSON(output: .all).hex
    }
}
