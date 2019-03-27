//
//  PublicKey.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// An ECC Public Key storing compressed key on binary format.
public struct PublicKey:
    PrefixedJsonCodableByProxy,
    CBORDataConvertible,
    DataInitializable,
    RadixHashable,
    Ownable,
    Hashable,
    CustomStringConvertible {
// swiftlint:enable colon
    
    public let compressedData: Data
    public init(data: Data) throws {
        self.compressedData = data
    }
}

// MARK: - PrefixedJsonCodableByProxy
public extension PublicKey {
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

// MARK: - Ownable
public extension PublicKey {
    var publicKey: PublicKey {
        return self
    }
}

// MARK: - CustomStringConvertible
public extension PublicKey {
    var description: String {
        return hex
    }
}

// MARK: - RadixHashable
public extension PublicKey {
    var radixHash: RadixHash {
        return RadixHash(unhashedData: compressedData)
    }
}

// MARK: - BitcoinKit
import BitcoinKit
public extension PublicKey {
    init(private privateKey: PrivateKey) {
        let bitcoinKitPrivateKey = privateKey.bitcoinKitPrivateKey
        let bitcoinKitPublicKey: BitcoinKit.PublicKey = bitcoinKitPrivateKey.publicKey()
        guard bitcoinKitPublicKey.isCompressed else {
            incorrectImplementation("Expected compressed public key")
        }
        do {
            try self.init(data: bitcoinKitPublicKey.data)
        } catch {
            incorrectImplementation("Should always be possible to create a PublicKey from a PrivateKey")
        }
    }
}
