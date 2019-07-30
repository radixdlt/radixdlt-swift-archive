//
//  HostConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol HostConvertible {
    var domain: String { get }
    var port: Port { get }
}

public extension HostConvertible {
    
    var isLocal: Bool {
        return domain == String.localhost
    }
}
