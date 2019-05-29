//
//  Message.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct SignableMessage:
    Signable,
    ExactLengthSpecifying,
    StringInitializable,
    DataInitializable,
    DataConvertible
{
    // swiftlint:enable colon opening_brace
    
    public static let length: Int = 32
    
    private let unsignedData: Data
    
    public init(data unsignedData: Data) throws {
        try SignableMessage.validateLength(of: unsignedData)
        self.unsignedData = unsignedData
    }
    
    public init(unhashed dataConvertible: DataConvertible, hashedBy hasher: Hashing = RadixHasher()) throws {
        let unhashed = dataConvertible.asData
        let hashed = hasher.hash(data: unhashed)
        try self.init(data: hashed)
    }
}

public extension SignableMessage {
    init(string: String, encoding: String.Encoding) throws {
        try self.init(data: string.toData(encodingForced: encoding))
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
public extension SignableMessage {
    init(string: String) throws {
        try self.init(string: string, encoding: .default)
    }
    
    enum Error: Swift.Error {
        case failedToEncodeMessage(encoding: String.Encoding)
    }
}

// MARK: - Signable
public extension SignableMessage {
    var signableData: Data {
        return unsignedData
    }
}

// MARK: - DataConvertible
public extension SignableMessage {
    var asData: Data {
        return unsignedData
    }
}
