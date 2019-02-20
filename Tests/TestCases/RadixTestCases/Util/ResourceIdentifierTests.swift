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

    func testResourceIdentifierEncodingAndDecoding() {
        let address: Address = "JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6"
        let resourceIdentifier = ResourceIdentifier(address: address, type: .tokens, unique: "Ada")
        let encoded = try! JSONEncoder().encode([resourceIdentifier])
        let decodedPlural = try! JSONDecoder().decode([ResourceIdentifier].self, from: encoded)
        let decoded = decodedPlural[0]
        XCTAssertEqual(decoded.address, resourceIdentifier.address)
        XCTAssertEqual(decoded.unique, resourceIdentifier.unique)
        XCTAssertEqual(decoded.type, resourceIdentifier.type)
        XCTAssertEqual(decoded.address, address)
        XCTAssertEqual(decoded.unique, "Ada")
        XCTAssertEqual(decoded.type, .tokens)
        XCTAssertEqual(Dson(value: resourceIdentifier).identifer, ":rri:/\(address)/tokens/Ada")
    }
}
