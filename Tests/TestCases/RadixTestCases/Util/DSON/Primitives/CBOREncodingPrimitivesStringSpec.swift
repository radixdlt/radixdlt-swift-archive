//
//  CBOREncodingPrimitivesStringSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class CBOREncodingPrimitivesStringSpec: QuickSpec {
    
    override func spec() {
        describe("DSON encoding") {
            describe("String = Radix") {
                it("should result in the appropriate data") {
                    expect("Radix".cborEncodedHexString()).to(equal("655261646978"))
                }
            }
        }
    }
}
