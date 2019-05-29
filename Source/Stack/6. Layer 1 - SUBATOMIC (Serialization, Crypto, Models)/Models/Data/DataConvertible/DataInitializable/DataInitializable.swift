//
//  DataInitializable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DataInitializable {
    init(data: Data) throws
}

public extension DataInitializable {
 
    init(base64: Base64String) throws {
        try self.init(data: base64.asData)
    }
    init(base58: Base58String) throws {
        try self.init(data: base58.asData)
    }
    
    init(hex: HexString) throws {
        try self.init(data: hex.asData)
    }
    
    init(base64String: String) throws {
        try self.init(base64: try Base64String(string: base64String))
    }
    
    init(base58String: String) throws {
        try self.init(base58: try Base58String(string: base58String))
    }
    
    init(hexString: String) throws {
        try self.init(hex: try HexString(string: hexString))
    }
}
