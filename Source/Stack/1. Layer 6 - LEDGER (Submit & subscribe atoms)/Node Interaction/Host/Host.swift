//
//  Host.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Host: Decodable, Hashable {
    public let ipAddress: String
    public let port: Port
    
    public init(ipAddress: String, port: Port) throws {
        guard !ipAddress.isEmpty else {
            throw Error.locationEmpty
        }
        self.ipAddress = ipAddress
        self.port = port
    }
}

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

public extension Host {
    static func local(port: Port = 8080) -> Host {
        do {
            return try Host(ipAddress: .localhost, port: port)
        } catch {
            incorrectImplementation("Failed to create localhost, error: \(error)")
        }
    }

    var isLocal: Bool {
        return ipAddress == String.localhost
    }
}