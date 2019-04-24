//
//  Host+Localhost.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

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
