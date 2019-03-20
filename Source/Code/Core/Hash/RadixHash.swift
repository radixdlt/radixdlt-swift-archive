//
//  RadixHash.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import CryptoSwift

// swiftlint:disable colon

/// Radix hash relies on the DSON encoding of a type.
public struct RadixHash:
    DataConvertible,
    ArrayConvertible,
    Hashable,
    CustomStringConvertible {
// swiftlint:enable colon

    private let data: Data
    
    // MARK: - Designated initializer
    public init(unhashedData: Data, hashedBy hasher: Hashing = Sha256TwiceHasher()) {
        self.data = hasher.hash(data: unhashedData)
    }
}

// MARK: - LengthMeasurable
public extension RadixHash {
    var length: Int {
        return bytes.length
    }
}

// MARK: - ArrayConvertible
public extension RadixHash {
    public typealias Element = Byte
    var elements: [Element] {
        return data.bytes
    }
}

// MARK: - DataConvertible
public extension RadixHash {
    var asData: Data {
        return data
    }
}

// MARK: - Hashable
public extension RadixHash {
    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
}

public extension RadixHash {
    
    func toEUID() -> EUID {
        do {
            return try EUID(data.prefix(EUID.length))
        } catch {
            incorrectImplementation("Should always be able to return EUID, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension RadixHash {
    var description: String {
        return toBase64String().stringValue
    }
}
