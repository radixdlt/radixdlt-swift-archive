//
//  Int+DataInitializable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension BinaryInteger {
    init(validData: Data) {
        self = validData.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) -> Self in
            return bytes.load(as: Self.self)
        })
    }
    
    init(data: Data) throws {
        let expectedByteCount = MemoryLayout<Self>.size
        if data.count > expectedByteCount {
            throw IntFromDataError.incorrectByteCount(expected: expectedByteCount, butGot: data.count)
        }
        self.init(validData: data)
    }
}

public enum IntFromDataError: Swift.Error {
    case incorrectByteCount(expected: Int, butGot: Int)
}

extension UInt8: DataInitializable {}
extension Int8: DataInitializable {}

extension UInt16: DataInitializable {}
extension Int16: DataInitializable {}

extension UInt32: DataInitializable {}
extension Int32: DataInitializable {}

extension UInt64: DataInitializable {}
extension Int64: DataInitializable {}

