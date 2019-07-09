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
    private let id: String
}

// MARK: - PotentiallyRequestIdentifiable
extension RPCResponseResultWithRequestId {
    var requestIdIfPresent: String? { return requestUuid }
}

extension RPCResponseResultWithRequestId {
    var requestUuid: String {
        return id
    }
}

internal extension RPCResponseResultWithRequestId {
    var model: Result { return result }
}

internal extension RPCResponseResultWithRequestId {
    typealias CodingKeys = RPCResponseResultWithRequestIdCodingKeys
}

internal enum RPCResponseResultWithRequestIdCodingKeys: String, CodingKey {
    case result, id
}
