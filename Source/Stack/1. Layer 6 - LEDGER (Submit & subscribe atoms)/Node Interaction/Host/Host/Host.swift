//
//  Host.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Host: Decodable, Hashable, URLConvertible {
    
    public let ipAddress: String
    public let port: Port
    
    public init(ipAddress: String, port: Port) throws {
        self.ipAddress = try URLFormatter.validating(isOnlyHost: ipAddress)
        self.port = port
    }
    
}

// MARK: - URLConvertible
public extension Host {
    var host: String {
        return ipAddress
    }
}
