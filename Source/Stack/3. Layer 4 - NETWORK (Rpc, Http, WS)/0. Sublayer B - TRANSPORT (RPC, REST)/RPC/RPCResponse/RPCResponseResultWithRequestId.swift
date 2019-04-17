//
//  RPCResponseResultWithRequestId.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

internal struct RPCResponseResultWithRequestId<Result>: Decodable, RPCResposeResultConvertible where Result: Decodable {
    let result: Result
    let id: Int
    var model: Result { return result }
}

// MARK: - PotentiallyRequestIdentifiable
extension RPCResponseResultWithRequestId {
    var requestIdIfPresent: Int? { return id }
}
