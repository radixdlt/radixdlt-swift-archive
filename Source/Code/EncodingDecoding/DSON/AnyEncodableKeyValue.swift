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
    
    internal let key: String
    private let dsonEncodedValue: DSON
    private let output: DSONOutput
    
    init(key unencodedKey: String, encoded dsonEncodedValue: DSON, output: DSONOutput) {
        self.key = unencodedKey
        self.dsonEncodedValue = dsonEncodedValue
        self.output = output
    }
}

public extension AnyEncodableKeyValue {
    func allowsOutput(of other: DSONOutput) -> Bool {
        return output.allowsOutput(of: other)
    }
    
    func cborEncoded() -> [UInt8] {
        return cborEncodedKey() + dsonEncodedValue
    }
}

private extension AnyEncodableKeyValue {
    func cborEncodedKey() -> [UInt8] {
        return CBOR.utf8String(key).encode()
    }
}

// MARK: - Convenience Init
public extension AnyEncodableKeyValue {
    init<Value>(key: String, encodable: Value, output: DSONOutput) throws where Value: DSONEncodable {
        self.init(key: key, encoded: try encodable.toDSON(output: output), output: output)
    }
}
