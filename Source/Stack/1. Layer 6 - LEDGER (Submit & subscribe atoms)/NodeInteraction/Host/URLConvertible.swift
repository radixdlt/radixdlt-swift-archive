//
//  URLConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol URLConvertible {
    var host: String { get }
    var port: Port { get }
}

public extension URLConvertible {
    
    var isLocal: Bool {
        return host == String.localhost
    }
}
