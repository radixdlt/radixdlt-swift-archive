//
//  RadixModelTypeStaticSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol RadixModelTypeStaticSpecifying {
    static var serializer: RadixModelType { get }
}

public extension RadixModelTypeStaticSpecifying {
    var serializer: RadixModelType {
        return Self.serializer
    }
}

extension Array: RadixModelTypeStaticSpecifying where Element: RadixModelTypeStaticSpecifying {
    public static var serializer: RadixModelType {
        return Element.serializer
    }
}
