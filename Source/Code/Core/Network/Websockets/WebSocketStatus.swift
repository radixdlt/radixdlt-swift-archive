//
//  WebSocketStatus.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum WebSocketStatus: String, Equatable, CustomStringConvertible {
    case connected, disconnected, failed, closing, connecting
}

extension CustomStringConvertible where Self: RawRepresentable, Self.RawValue == String {
    public var description: String {
        return rawValue
    }
}
