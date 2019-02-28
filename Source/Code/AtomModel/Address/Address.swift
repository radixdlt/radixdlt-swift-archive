//
//  Address.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Address: PrefixedJsonCodableByProxy, Hashable, CustomStringConvertible, DataConvertible, ExactLengthSpecifying {
    
    public static let length = 51
    
    public let base58String: Base58String
    public let publicKey: PublicKey
    
    public init(base58String: Base58String, publicKey: PublicKey? = nil) throws {
        try Address.validateLength(of: base58String)
        try Address.isChecksummed(base58String: base58String)
        self.base58String = base58String
        let addressData = base58String.asData
        self.publicKey = publicKey ?? PublicKey(data: addressData[1...addressData.count - 5])
    }
    
}

// MARK: - PrefixedJsonDecodableByProxy
public extension Address {
    public typealias Proxy = Base58String
    var proxy: Proxy {
        return base58String
    }
    init(proxy: Proxy) throws {
        try self.init(base58String: proxy)
    }
}

// MARK: - DataConvertible
public extension Address {
    var asData: Data {
        return base58String.asData
    }
}

// MARK: - Convenience Init
public extension Address {
    init(publicKey: PublicKey, magic: Magic) {
        implementMe
    }
    
    init(publicKey: PublicKey, universeConfig: UniverseConfig) {
        self.init(publicKey: publicKey, magic: universeConfig.magic)
    }
}

// MARK: - StringInitializable
public extension Address {
    init(string: String) throws {
        let base58 = try Base58String(string: string)
        try self.init(base58String: base58)
    }
}
// MARK: - CustomStringConvertible
public extension Address {
    var description: String {
        return base58String.value
    }
}

// MARK: - Checksum
public extension Address {
    
    static func isChecksummed(base58String: Base58String) throws {
        let data = base58String.asData
        let dropCount = 4
        let head = data.dropLast(dropCount)
        let tail = data.suffix(dropCount)
        let checksumCheck = RadixHash(unhashedData: head, hashedBy: Sha256TwiceHasher())
        for (index, byte) in tail.enumerated() {
            guard checksumCheck[index] == byte else {
                throw Error.checksumMismatch
            }
        }
        // is valid
    }
    
    public enum Error: Swift.Error {
        case checksumMismatch
    }
}
