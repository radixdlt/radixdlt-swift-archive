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
        let manual = ResourceIdentifier(address: "JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6", type: .tokenClass, unique: "Ada")
        let encoded = try! JSONEncoder().encode([manual])
        let decodedPlural = try! JSONDecoder().decode([ResourceIdentifier].self, from: encoded)
        let decoded = decodedPlural[0]
        XCTAssertEqual(decoded.address, manual.address)
        XCTAssertEqual(decoded.unique, manual.unique)
        XCTAssertEqual(decoded.type, manual.type)
        XCTAssertEqual(decoded.address, "JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6")
        XCTAssertEqual(decoded.unique, "Ada")
        XCTAssertEqual(decoded.type, .tokenClass)
        //        let dson = Dson(tag: .uri, rawValueString: decoded.identifier)
        //        XCTAssertEqual(dson.taggedValueString, ":rri:/JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6/tokenclasses/Ada")
    }
}
