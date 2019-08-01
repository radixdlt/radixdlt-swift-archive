//
//  AtomNotStoredReason.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-08-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AtomNotStoredReason: Equatable, CustomStringConvertible {
    let reason: AtomStatusNotStored
    let error: SubmitAtomError
    
    init(_ reason: AtomStatusNotStored, error: SubmitAtomError) {
        self.reason = reason
        self.error = error
    }
    
    init(atomStatus: AtomStatus, dataAsJsonString: String) {
        self.init(
            AtomStatusNotStored(atomStatus: atomStatus),
            error: SubmitAtomError(rpcError: RPCError.unrecognizedJson(jsonString: dataAsJsonString))
        )
    }
}

public extension AtomNotStoredReason {
    var description: String {
        return """
        reason: \(reason), error: \(error)
        """
    }
}
