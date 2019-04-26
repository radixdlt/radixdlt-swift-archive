//
//  ResourceIdentifierTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class ResourceIdentifierTests: XCTestCase {
    
    func testResourceIdentifierString() {
        // GIVEN
        // An address
        let address: Address = "JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6"
        // WHEN
        // A create a RRI for the address and some name
        let identifier = ResourceIdentifier(address: address, name: "Ada")
        // THEN
        // I get the expected symbol
        XCTAssertEqual(identifier.identifier, "/JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6/Ada")
    }
}
