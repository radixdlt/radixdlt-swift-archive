//
//  RadixHash.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import CryptoSwift

public protocol Hashing {
    func hash(data: Data) -> Data
}

public struct Sha256Hasher: Hashing {
    public init() {}
    public func hash(data: Data) -> Data {
        return data.sha256()
    }
}

public struct Sha256TwiceHasher: Hashing {
    public init() {}
    public func hash(data: Data) -> Data {
        return data.sha256().sha256()
    }
}

public struct RadixHash: Hashable, CustomStringConvertible {
    private let data: Data
    public init(unhashedData: Data, hashedBy hasher: Hashing) {
        self.data = hasher.hash(data: unhashedData)
    }
}

// MARK: - Hashable
public extension RadixHash {
    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
}

public extension RadixHash {
    
    func toHexString() -> HexString {
        return HexString(data: data)
    }
    
    func toBase64String() -> Base64String {
        return Base64String(data: data)
    }
    
    func toEUID() -> EUID {
        var dataToPad = self.data
        do {
            return try EUID(data: Data(bytes: &dataToPad, count: EUID.byteCount))
        } catch {
            incorrectImplementation("Should always be able to return EUID, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension RadixHash {
    var description: String {
        return toBase64String().value
    }
}
