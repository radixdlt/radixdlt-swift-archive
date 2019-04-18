//
//  RPCResposeResultConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

protocol PotentiallyRequestIdentifiable {
    var requestIdIfPresent: Int? { get }
}

extension PotentiallyRequestIdentifiable {
    var requestIdIfPresent: Int? { return nil }
}

internal protocol RPCResposeResultConvertible: Decodable, PotentiallyRequestIdentifiable {
    associatedtype Model: Decodable
    var model: Model { get }
}
