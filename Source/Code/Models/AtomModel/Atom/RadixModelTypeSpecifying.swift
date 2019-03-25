//
//  RadixModelTypeStaticSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol RadixModelTypeStaticSpecifying {
    static var type: RadixModelType { get }
}

public extension RadixModelTypeStaticSpecifying {
    var type: RadixModelType {
        return Self.type
    }
}
