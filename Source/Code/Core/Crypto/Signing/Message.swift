//
//  Message.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon
public struct Message:
    Signable,
    ExactLengthSpecifying,
    StringInitializable,
    DataInitializable,
    DataConvertible {
    // swiftlint:enable colon
    
    public static let length: Int = 32
    
    private let unsignedData: Data
    
    public init(data unsignedData: Data) throws {
        try Message.validateLength(of: unsignedData)
        self.unsignedData = unsignedData
    }
    
    public init(unhashed dataConvertible: DataConvertible, hashedBy hasher: Hashing = RadixHasher()) throws {
        let unhashed = dataConvertible.asData
        let hashed = hasher.hash(data: unhashed)
        try self.init(data: hashed)
    }
}

public extension Message {
    init(string: String, encoding: String.Encoding) throws {
        guard let encoded = string.data(using: encoding) else {
            throw Error.failedToEncodeMessage(encoding: encoding)
        }
        try self.init(data: encoded)
    }
    
    init(hash: RadixHash) {
        do {
            try self.init(data: hash.asData)
        } catch {
            incorrectImplementation("Should work")
        }
    }
}

// MARK: - StringInitializable
public extension Message {
    init(string: String) throws {
        try self.init(string: string, encoding: .utf8)
    }
    
    enum Error: Swift.Error {
        case failedToEncodeMessage(encoding: String.Encoding)
    }
}

// MARK: - Signable
public extension Message {
    var signableData: Data {
        return unsignedData
    }
}

// MARK: - DataConvertible
public extension Message {
    var asData: Data {
        return unsignedData
    }
}
