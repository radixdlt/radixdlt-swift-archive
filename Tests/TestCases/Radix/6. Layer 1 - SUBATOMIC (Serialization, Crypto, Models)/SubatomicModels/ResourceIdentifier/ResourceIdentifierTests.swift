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
                let identifier = ResourceIdentifier(address: address, name: "Ada")
                
                it("should have the correct name") {
                    expect(identifier.name).to(equal("Ada"))
                }
                
                it("should have the correct identifier") {
                    expect(identifier.identifier).to(equal("/JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6/Ada"))
                }
            }
        }
    }
}
