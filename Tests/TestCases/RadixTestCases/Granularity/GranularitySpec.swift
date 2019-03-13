//
//  GranularitySpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import Nimble
import Quick

class GranularitySpec: QuickSpec {
    override func spec() {
        describe("Granularity of 1 to hex") {
            it("It should contain 63 leading zeros") {
                let gran: Granularity = 1
                let hexString = gran.asData.hex
                expect(hexString).to(equal("0000000000000000000000000000000000000000000000000000000000000001"))
            }
        }
    }
}
