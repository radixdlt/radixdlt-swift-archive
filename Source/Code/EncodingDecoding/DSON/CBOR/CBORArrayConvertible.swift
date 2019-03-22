//
//  CBORArrayConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DSONArrayConvertible: DSONEncodable, ArrayConvertible {
    func dsonEncodeElement(_ element: Element, output: DSONOutput) throws -> DSON
}

public extension DSONArrayConvertible where Element: DSONEncodable {
    func dsonEncodeElement(_ element: Element, output: DSONOutput = .default) throws -> DSON {
        return try element.toDSON(output: output)
    }
}

// MARK: - DSONEncodable
public extension DSONArrayConvertible where Element: DSONEncodable {
    func toDSON(output: DSONOutput = .default) throws -> DSON {
        return try [Element](self).toDSON(output: output)
    }
}

extension Array: DSONEncodable where Element: DSONEncodable {
    public func toDSON(output: DSONOutput = .default) throws -> DSON {
        var array = try count.encode() + self.flatMap { try $0.toDSON(output: output) }
        // Bit mask for CBOR major type 4 (array): 0b100 << 1 <=> 0b1000
        array[0] |= 0b100_00000
        return array.asData
    }
}

