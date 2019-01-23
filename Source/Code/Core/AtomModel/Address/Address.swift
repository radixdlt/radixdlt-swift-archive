//
//  Address.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Address: Equatable, Codable {
    
    public static let length = 51
    
    public enum Error: Swift.Error {
        case tooLong(expected: Int, butGot: Int)
        case tooShort(expected: Int, butGot: Int)
        case nonBase58(error: Base58String.Error)
    }
    
    internal let base58String: Base58String
    
    public init(base58String: Base58String) throws {
        if base58String.length > Address.length {
            throw Error.tooLong(expected: Address.length, butGot: base58String.length)
        }
        
        if base58String.length < Address.length {
            throw Error.tooShort(expected: Address.length, butGot: base58String.length)
        }
        
        self.base58String = base58String
    }
}

public extension Address {
    init(string: String) throws {
        do {
            let base58 = try Base58String(string: string)
            try self.init(base58String: base58)
        } catch let base58Error as Base58String.Error {
            throw Address.Error.nonBase58(error: base58Error)
        }
    }
}
