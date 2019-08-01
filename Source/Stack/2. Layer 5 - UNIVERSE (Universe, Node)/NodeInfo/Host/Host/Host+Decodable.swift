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
        case domain = "ip"
        case port
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let portValue = try container.decode(Int.self, forKey: .port)
        let port: Port
        do {
            port = try Port(unvalidated: portValue)
        } catch let error as Port.Error {
            throw Error.badPort(error)
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
        
        let domain = try container.decode(StringValue.self, forKey: .domain).stringValue
        
        try self.init(domain: domain, port: port)
    }
}

// MARK: - Throwing
public extension Host {
    enum Error: Swift.Error, Equatable {
        case badPort(Port.Error)
        case locationEmpty
    }
}
