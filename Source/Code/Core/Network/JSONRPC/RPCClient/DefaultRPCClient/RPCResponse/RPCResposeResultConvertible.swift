//
//  RPCResposeResultConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

internal protocol RPCResposeResultConvertible: Decodable {
    associatedtype Model: Decodable
    var model: Model { get }
}
