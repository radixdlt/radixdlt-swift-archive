//
//  BytesValue.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-10.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

public struct BytesValue:
    PrefixedJsonCodableByProxy,
    CBORDataConvertible,
    DataInitializable,
Hashable {
    // swiftlint:enable colon
    
    public let data: Data
    public init(data: Data) throws {
        self.data = data
    }
    
    public init?(dataIfPresent data: Data?) {
        guard let data = data else {
            return nil
        }
        self.data = data
    }
}

// MARK: - PrefixedJsonCodableByProxy
public extension BytesValue {
    typealias Proxy = Base64String
    static let jsonPrefix = JSONPrefix.bytesBase64
    var proxy: Proxy {
        return toBase64String()
    }
    init(proxy: Proxy) throws {
        try self.init(base64: proxy)
    }
}

// MARK: - StringInitializable
public extension BytesValue {
    init(string: String) throws {
        let base64 = try Base64String(string: string)
        try self.init(base64: base64)
    }
}

// MARK: - DataConvertible
public extension BytesValue {
    var asData: Data { return data }
}
