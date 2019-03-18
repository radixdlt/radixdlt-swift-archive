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

//swiftlint:disable:next colon
public struct RadixHash:
    DataConvertible,
    Hashable,
    CustomStringConvertible,
    Collection {

    private let data: Data
    public init(unhashedData: Data, hashedBy hasher: Hashing) {
        self.data = hasher.hash(data: unhashedData)
    }
}

// MARK: - Collection
public extension RadixHash {
    public typealias Element = Byte
    typealias Index = Array<Element>.Index
    var startIndex: Index {
        return data.startIndex
    }
    var endIndex: Index {
        return data.endIndex
    }
    subscript(position: Index) -> Element {
        return data[position]
    }
    func index(after index: Index) -> Index {
        return data.index(after: index)
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
        var dataToPad = self.data
        do {
            return try EUID(Data(bytes: &dataToPad, count: EUID.byteCount))
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
