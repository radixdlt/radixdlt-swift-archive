//
//  Host+Localhost.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Host {
    static func local(port: Port = .localhost) -> Host {
        do {
            return try Host(domain: .localhost, port: port)
        } catch {
            incorrectImplementation("Failed to create localhost, error: \(error)")
        }
    }
    
    var isLocal: Bool {
        return domain == String.localhost
    }
}
