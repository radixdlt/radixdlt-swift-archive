//
//  JSONRPCRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import JSONRPCKit

public extension JSONRPCKit.Request {
    
    /// Radix API enforces the existance of `params`, so must return empty string rather than `nil` (by default).
    var parameters: Encodable? {
        return ""
    }
}
