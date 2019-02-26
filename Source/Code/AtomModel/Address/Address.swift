//
//  Address.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ExactLengthSpecifying: MinLengthSpecifying, MaxLengthSpecifying {
    static var length: Int { get }
}
public extension ExactLengthSpecifying {
    static var minLength: Int {
        return length
    }
    static var maxLength: Int {
        return length
    }
}

public struct Address: PrefixedJsonDecodableByProxy, StringInitializable, Hashable, Codable, CustomStringConvertible, DataConvertible, ExpressibleByStringLiteral, ExactLengthSpecifying {
    
    public static let length = 51
    
    public let base58String: Base58String
    public let publicKey: PublicKey
    
    public init(base58String: Base58String, publicKey: PublicKey? = nil) throws {
        try Address.isChecksummed(base58String: base58String)
        self.base58String = base58String
        let addressData = base58String.asData
        self.publicKey = publicKey ?? PublicKey(data: addressData[1...addressData.count - 5])
    }
}

// MARK: - PrefixedJsonDecodableByProxy
public extension Address {
    init(proxy: Base58String) throws {
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
        do {
            let base58 = try Base58String(string: string)
            try self.init(base58String: base58)
        } catch let base58Error as InvalidStringError {
            throw Address.Error.nonBase58(error: base58Error)
        }
    }
}

// MARK: - ExpressibleByStringLiteral
public extension Address {
    public init(stringLiteral value: String) {
        do {
            try self.init(string: value)
        } catch {
            fatalError("Passed non address value string: `\(value)`, error: \(error)")
        }
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
        case tooLong(expected: Int, butGot: Int)
        case tooShort(expected: Int, butGot: Int)
        case nonBase58(error: InvalidStringError)
        case checksumMismatch
    }
}
