//
//  AddressEUIDSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class AddressEUIDSpec: QuickSpec {
    
    override func spec() {
        let address = try! Address(base58String: "JHB89drvftPj6zVCNjnaijURk8D8AMFw4mVja19aoBGmRXWchnJ")
        describe("Address EUID") {
            it("Should equal the value from Java library") {
                expect(address.hashId).to(equal("8cfef50ea6a767813631490f9a94f73f"))
                
            }
        }
    }
}
