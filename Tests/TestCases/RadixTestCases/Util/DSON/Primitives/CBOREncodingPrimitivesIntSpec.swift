//
//  CBOREncodingPrimitivesIntSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick


class CBOREncodingPrimitivesIntSpec: QuickSpec {
    
    override func spec() {
        describe("DSON encoding") {
            describe("Int = 10") {
                it("should result in the appropriate data") {
                    expect(10.cborEncodedHexString()).to(equal("0a"))
                }
            }
            
            describe("Int = -1") {
                it("should result in the appropriate data") {
                    expect(Int(-1).cborEncodedHexString()).to(equal("20"))
                }
            }
        }
    }
}
