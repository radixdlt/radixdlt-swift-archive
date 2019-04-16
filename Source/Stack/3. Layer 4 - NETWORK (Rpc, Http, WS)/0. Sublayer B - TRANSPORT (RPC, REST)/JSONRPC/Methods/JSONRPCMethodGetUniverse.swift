//
//  JSONRPCMethodGetUniverse.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct JSONRPCMethodGetUniverse: JSONRPCKit.Request {
    public typealias Response = UniverseConfig
    public let method = "Universe.getUniverse"
}
