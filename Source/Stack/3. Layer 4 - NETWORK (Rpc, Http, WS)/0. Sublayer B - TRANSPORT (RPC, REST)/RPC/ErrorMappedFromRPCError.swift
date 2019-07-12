//
//  ErrorMappedFromRPCError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

internal protocol ErrorMappedFromRPCError: Swift.Error {
    init(rpcError: RPCError)
}

// So that we can pass no error mapper, by passing Generic Optional problem, by using ` let noMapper: ((RPCError) -> RPCError)? = nil`
extension RPCError: ErrorMappedFromRPCError {
    init(rpcError: RPCError) {
        self = rpcError
    }
}
