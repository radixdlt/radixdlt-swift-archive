//
//  ResourceIdentifierTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

@testable import RadixSDK
import Nimble
import Quick

class ResourceIdentifierSpec: QuickSpec {
    
    override func spec() {
        let address: Address = "JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6"
        describe("Resource Identifier") {
            describe("Of type tokens") {
                let identifier = ResourceIdentifier(address: address, type: .tokens, name: "Ada")
                it("should have the correct type") {
                    expect(identifier.type).to(equal(.tokens))
                }
                
                it("should have the correct unique") {
                    expect(identifier.unique).to(equal("Ada"))
                }
                
                it("should have the correct identifier") {
                    expect(identifier.identifier).to(equal("/\(address.base58)/tokens/Ada"))
                }
            }
        }
    }
}
