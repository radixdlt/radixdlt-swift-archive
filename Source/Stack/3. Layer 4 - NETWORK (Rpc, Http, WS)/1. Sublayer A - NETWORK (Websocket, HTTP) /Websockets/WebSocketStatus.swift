//
//  WebSocketStatus.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum WebSocketStatus: String, Hashable, CustomStringConvertible, CaseIterable {
    case disconnected
    
    case connecting
//    case connected
    case ready

    case closing
    case failed
}

public extension WebSocketStatus {
//    var isConnected: Bool {
//        return statusIs(.connected)
//    }
    
    var isReady: Bool {
        return statusIs(.ready)
    }

    var isDisconnected: Bool {
        return statusIs(.disconnected)
    }
    
    func statusIs(_ `case`: WebSocketStatus) -> Bool {
        return enumCase(is: `case`)
    }
}

extension RawRepresentable where Self.RawValue: Equatable {
    func enumCase(is `case`: Self) -> Bool {
        return self.rawValue == `case`.rawValue
    }
}

extension CustomStringConvertible where Self: RawRepresentable, Self.RawValue == String {
    public var description: String {
        return rawValue
    }
}
