//
//  Host.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable opening_brace colon

public struct Host:
    HostConvertible,
    Throwing,
    Decodable,
    Hashable
{
    // swiftlint:enable opening_brace colon
    
    public let domain: String
    public let port: Port
    
    public init(domain: String, port: Port) throws {
        self.domain = try URLFormatter.validating(isOnlyHost: domain)
        self.port = port
    }
    
}
