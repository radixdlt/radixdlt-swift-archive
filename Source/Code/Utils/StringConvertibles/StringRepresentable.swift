//
//  StringRepresentable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol LengthMeasurable {
    var length: Int { get }
}

extension Array: LengthMeasurable {
    public var length: Int { return count }
}

public protocol StringRepresentable: LengthMeasurable {
    var stringValue: String { get }
}

public extension StringRepresentable {
    public var length: Int {
        return stringValue.length
    }
}

public extension StringRepresentable where Self: DataConvertible {
    public var length: Int {
        return stringValue.length
    }
}

extension String: LengthMeasurable {
    public var length: Int {
        return count
    }
}

public extension StringRepresentable where Self: RawRepresentable, Self.RawValue == String {
    var stringValue: String {
        return rawValue
    }
}

extension String: StringRepresentable {
    public var stringValue: String {
        return self
    }
}
