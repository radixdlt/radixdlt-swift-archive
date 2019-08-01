//
//  SubmitAtomError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SubmitAtomError: ErrorMappedFromRPCError, Equatable, CustomStringConvertible {
    public let rpcError: RPCError
    init(rpcError: RPCError) {
        self.rpcError = rpcError
    }
}

public extension SubmitAtomError {
    var description: String {
        return """
            SubmitAtomError(\(rpcError))
        """
    }
}
