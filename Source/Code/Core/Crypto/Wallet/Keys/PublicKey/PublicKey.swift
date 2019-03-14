//
//  PublicKey.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct PublicKey: PrefixedJsonCodableByProxy, Hashable, CBORDataConvertible, DataInitializable {
    
    public let compressedData: Data
    public init(data: Data) throws {
        self.compressedData = data
    }
}

// MARK: - Convenience init
public extension PublicKey {
    init(private privateKey: PrivateKey) {
        implementMe
    }
}

// MARK: - PrefixedJsonCodableByProxy
public extension PublicKey {
    public typealias Proxy = Base64String
    static let jsonPrefix = JSONPrefix.bytesBase64
    var proxy: Proxy {
        return toBase64String()
    }
    init(proxy: Proxy) throws {
        try self.init(base64: proxy)
    }
}

// MARK: - StringInitializable
public extension PublicKey {
    init(string: String) throws {
        let base64 = try Base64String(string: string)
        try self.init(base64: base64)
    }
}

// MARK: - DataConvertible
public extension PublicKey {
    var asData: Data { return compressedData }
}

// MARK: - CustomStringConvertible
public extension PublicKey {
    var description: String {
        return hex
    }
}
