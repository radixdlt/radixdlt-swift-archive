//
//  Address.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Address: Hashable, Codable, CustomStringConvertible {
    
    public static let length = 51
    
    public enum Error: Swift.Error {
        case tooLong(expected: Int, butGot: Int)
        case tooShort(expected: Int, butGot: Int)
        case nonBase58(error: Base58String.Error)
        case checksumMismatch
    }
    
    internal let base58String: Base58String
    public let publicKey: PublicKey
    
    public init(base58String: Base58String, publicKey: PublicKey? = nil) throws {
        if base58String.length > Address.length {
            throw Error.tooLong(expected: Address.length, butGot: base58String.length)
        }
        
        if base58String.length < Address.length {
            throw Error.tooShort(expected: Address.length, butGot: base58String.length)
        }
       
        try Address.isChecksummed(base58String: base58String)
        self.base58String = base58String
        self.publicKey = publicKey ?? PublicKey(data: base58String.asData[1...base58String.length - 5])
    }
}

// MARK: - Convenience Init
public extension Address {
    init(string: String) throws {
        do {
            let base58 = try Base58String(string: string)
            try self.init(base58String: base58)
        } catch let base58Error as Base58String.Error {
            throw Address.Error.nonBase58(error: base58Error)
        }
    }
    
    init(publicKey: PublicKey, magic: Magic) {
        implementMe
//        let addressData =
    }
    
    init(publicKey: PublicKey, universeConfig: UniverseConfig) {
        self.init(publicKey: publicKey, magic: universeConfig.magic)
    }
}

// MARK: - CustomStringConvertible
public extension Address {
    var description: String {
        return base58String.value
    }
}

public extension Address {
    static func isChecksummed(base58String: Base58String) throws {
        let data = base58String.asData
        let offset = base58String.length - 4
        let checksumCheck = RadixHash(unhashedData: data.prefix(offset), hashedBy: Sha256TwiceHasher())
        for index in 0..<4 {
            guard checksumCheck[index] == data[offset + index] else {
                throw Error.checksumMismatch
            }
        }
        // is valid
    }
}
