//
//  RPCResponseLookingLikeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

internal struct RPCResponseLookingLikeRequest<Params>: Decodable, RPCResposeResultConvertible where Params: Decodable {
    let params: Params
    let method: String
    var model: Params { return params }
}
