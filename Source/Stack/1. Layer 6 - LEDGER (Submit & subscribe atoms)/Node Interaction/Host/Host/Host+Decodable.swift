//
//  Host+Decodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Decodable
public extension Host {
    enum CodingKeys: String, CodingKey {
        case ipAddress = "ip"
        case port
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let portValue = try container.decode(Int.self, forKey: .port)
        let port: Port
        do {
            port = try Port(unvalidated: portValue)
        } catch {
            throw Error.badPort(error)
        }
        let ipAddress = try container.decode(StringValue.self, forKey: .ipAddress).stringValue
        
        try self.init(ipAddress: ipAddress, port: port)
    }
}

// MARK: - Validation
public extension Host {
    enum Error: Swift.Error {
        case badPort(Swift.Error)
        case locationEmpty
    }
}
