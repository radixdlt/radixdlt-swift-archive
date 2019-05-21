//
//  RPCErrorCode.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// https://www.jsonrpc.org/specification
public enum RPCErrorCode: Int, Swift.Error, Decodable, Equatable {
    case serverError = -32000 // use for error: "Subscriber already exists"
    case parseError = -32700
    case invalidRequest = -32600
    case methodNotFound = -32601 // 1044 = not found, 1045 = endpoint retired,
    case invalidParams = -32602 // 1042 = out of range, 1043 = unauthorixed
    case internalError = -32603 // 1046 = limit exceeded
}

