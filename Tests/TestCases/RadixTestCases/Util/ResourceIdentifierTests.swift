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
//    func testResourceIdentifierEncodingAndDecoding() {
//        let address: Address = "JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6"
//        let resourceIdentifier = ResourceIdentifier(address: address, type: .tokens, unique: "Ada")
//        let jsonEncoder = JSONEncoder()
//        jsonEncoder.outputFormatting = .prettyPrinted
//        let encoded = try! jsonEncoder.encode([resourceIdentifier])
//        let jsonString = String(data: encoded, encoding: .utf8)!
//
//        XCTAssertEqual(jsonString, "[\(resourceIdentifier.identifier)]")
//        let decodedPlural: [ResourceIdentifier] = try! JSONDecoder().decodeDson([ResourceIdentifier].self, from: encoded)
//        let decoded = decodedPlural[0]
//        XCTAssertEqual(decoded.address, resourceIdentifier.address)
//        XCTAssertEqual(decoded.unique, resourceIdentifier.unique)
//        XCTAssertEqual(decoded.type, resourceIdentifier.type)
//        XCTAssertEqual(decoded.address, address)
//        XCTAssertEqual(decoded.unique, "Ada")
//        XCTAssertEqual(decoded.type, .tokens)
//        XCTAssertEqual(Dson(value: resourceIdentifier).identifer, ":rri:/\(address)/tokens/Ada")
//    }
}
