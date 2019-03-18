//
//  AnyEncodableKeyValue.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A fully type-erased container of a keyed-value that is DSONEncodable
public struct AnyEncodableKeyValue {
    public let key: String
    public let dsonEncodedValue: DSON
    public let output: DSONOutput
    init(key unencodedKey: String, encoded dsonEncodedValue: DSON, output: DSONOutput) {
        self.key = unencodedKey
        self.dsonEncodedValue = dsonEncodedValue
        self.output = output
    }
    
    init<Value>(key: String, encodable: Value, output: DSONOutput = .default) throws where Value: DSONEncodable {
        self.init(key: key, encoded: try encodable.toDSON(output: output), output: output)
    }
    
    public func cborEncodedKey() -> [UInt8] {
        return CBOR.utf8String(key).encode()
    }
}
