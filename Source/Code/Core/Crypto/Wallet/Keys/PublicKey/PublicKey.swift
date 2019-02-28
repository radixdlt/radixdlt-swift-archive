//
//  PublicKey.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct PublicKey: PrefixedJsonCodableByProxy, Hashable, DataConvertible {
    
    public let data: Data
    public init(data: Data) {
        self.data = data
    }
}

// MARK: - Convenience init
public extension PublicKey {
    init(private privateKey: PrivateKey) {
        implementMe
    }
    
    init(hexString: HexString) throws {
        self.init(data: hexString.asData)
    }
    
    init(base64: Base64String) throws {
        self.init(data: base64.asData)
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
    var asData: Data { return data }
}

// MARK: - CustomStringConvertible
public extension PublicKey {
    var description: String {
        return hex
    }
}

public extension PublicKey {
    func toBase64String() -> Base64String {
        return Base64String(data: data)
    }
    
    func toHexString() -> HexString {
        return HexString(data: data)
    }
}
