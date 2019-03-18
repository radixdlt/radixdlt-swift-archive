//
//  DSONEncodingExampleMapSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick


/// DSON encoding of example map from: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
class DSONEncodingExampleMapSpec: QuickSpec {
    
    public struct ExampleMap: CBORStreamable {
        let a: Int = 1
        let b: Int = 2
        
        public enum CodingKeys: String, CodingKey {
            case a
            case b
        }
        
        public func processProperties(_ properties: [CBOREncodableProperty]) throws -> [CBOREncodableProperty] {
            return properties
        }
        
        public func keyValues() throws -> [EncodableKeyValue<CodingKeys>] {
            return [
                EncodableKeyValue(key: .a, value: a),
                EncodableKeyValue(key: .b, value: b)
            ]
        }
    }
    
    override func spec() {
        let exampleMap = ExampleMap()
        describe("DSON encoding - ExampleMap") {
            it("should result in the appropriate data") {
                let exampleMapDsonEncoded = try! exampleMap.toDSON()
                expect(exampleMapDsonEncoded.hex)
                    .to(equal("bf616101616202ff"))
                
            }
        }
    }
}
