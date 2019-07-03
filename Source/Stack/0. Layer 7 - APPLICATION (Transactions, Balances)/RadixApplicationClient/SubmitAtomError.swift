//
//  SubmitAtomError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SubmitAtomError: ErrorMappedFromRPCError, Equatable {
    public let rpcError: RPCError
    init(rpcError: RPCError) {
        self.rpcError = rpcError
    }
}

public struct DiscoverMoreNodesActionError: NodeAction {
    public let reason: Swift.Error
}
