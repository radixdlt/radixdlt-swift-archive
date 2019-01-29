//
//  Int+DataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension BinaryInteger {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Self>.size)
    }
}

extension Int64: DataConvertible {
    public var asData: Data {
        return data
    }
}

extension Int32: DataConvertible {
    public var asData: Data {
        return data
    }
}

extension Int8: DataConvertible {
    public var asData: Data {
        return data
    }
}

extension UInt64: DataConvertible {
    public var asData: Data {
        return data
    }
}

extension UInt32: DataConvertible {
    public var asData: Data {
        return data
    }
}

extension UInt8: DataConvertible {
    public var asData: Data {
        return data
    }
}
