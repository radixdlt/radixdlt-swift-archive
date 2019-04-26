//
//  DSONEncodingExampleMapSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

/// DSON encoding of example map from: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
class DSONEncodingExampleMapTests: XCTestCase {
    
    func testDsonEncodingOfSimpleMap() {
        // GIVEN
        // An simple map
        let exampleMap = ExampleMap()
        
        // WHEN
        // I try to DSON encode it
        guard let dsonHex = dsonHexStringOrFail(exampleMap) else { return }
        
        // THEN
        // It should equal the expected result of "Radix Type" `map`, the table in the link provided above
        XCTAssertEqual(dsonHex, "bf616101616202ff")
    }
}

private struct ExampleMap: RadixCodable {
    let a: Int = 1
    let b: Int = 2
    
    public enum CodingKeys: String, CodingKey {
        case a
        case b
    }
    
    public var preProcess: Process {
        return { values, _ in return values }
    }
    
    public func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .a, value: a),
            EncodableKeyValue(key: .b, value: b)
        ]
    }
}
