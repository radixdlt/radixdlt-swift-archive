//
//  BigInteger+StringConversion.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension BigInteger {
    
    func toHexString(uppercased: Bool = true) -> HexString {
        let string = toString(uppercased: uppercased, radix: 16)
        do {
            return try HexString(string: string)
        } catch {
            incorrectImplementation("Should always be able to create HexString, error: \(error)")
        }
    }
    
    func toDecimalString(uppercased: Bool = true) -> String {
        return toString(uppercased: uppercased, radix: 10)
    }
    
    func toString(uppercased: Bool = true, radix: Int) -> String {
        let stringRepresentation = String(self, radix: radix)
        guard uppercased else { return stringRepresentation }
        return stringRepresentation.uppercased()
    }
        
    var asData: Data {
        return Data(hex: toHexString().value)
    }
}

extension Data: DataConvertible {
    
    public var asData: Data {
        return self
    }
    
    public func toData(minByteCount: Int? = nil) -> Data {
        guard let minByteCount = minByteCount else {
            return self
        }
        var bytes = self.bytes
        while bytes.count < minByteCount {
            bytes = [Byte(0x0)] + bytes
        }
        return Data(bytes: bytes)
    }
}

func * <I>(lhs: I, rhs: I?) -> I? where I: BinaryInteger {
    guard let rhs = rhs else {
        return nil
    }
    return lhs * rhs
}

extension String {
    func append(character: Character, toLength expectedLength: Int?) -> String {
        return prependingOrAppending(character: character, toLength: expectedLength, mode: .append)
    }
    
    func prepending(character: Character, toLength expectedLength: Int?) -> String {
        return prependingOrAppending(character: character, toLength: expectedLength, mode: .prepend)
    }
    
    private enum ConcatMode {
        case prepend
        case append
    }
    
    private func prependingOrAppending(character: Character, toLength expectedLength: Int?, mode: ConcatMode) -> String {
        guard let expectedLength = expectedLength else {
            return self
        }
        var modified = self
        let new = String(character)
        while modified.length < expectedLength {
            switch mode {
            case .prepend: modified = new + modified
            case .append: modified += new
            }
   
        }
        return modified
    }
}
