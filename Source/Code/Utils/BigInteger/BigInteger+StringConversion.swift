//
//  BigInteger+StringConversion.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BigInt
public extension BigInt {
    
    func serialize() -> Data {
        var array = Array(BigUInt.init(self.magnitude).serialize())
        
        if array.count > 0 {
            if self.sign == BigInt.Sign.plus {
                if array[0] >= 128 {
                    array.insert(0, at: 0)
                }
            } else if self.sign == BigInt.Sign.minus {
                if array[0] <= 127 {
                    array.insert(255, at: 0)
                }
            }
        }
        
        return Data.init(bytes: array)
    }
    
    // swiftlint:disable:next function_body_length
    init(_ data: Data) {
        var dataArray = Array(data)
        var sign: BigInt.Sign = BigInt.Sign.plus
        
        if dataArray.count > 0 {
            if dataArray[0] >= 128 {
                sign = BigInt.Sign.minus
                
                if dataArray.count > 1 {
                    if dataArray[0] == 255, dataArray.count > 1 {
                        dataArray.remove(at: 0)
                    } else {
                        dataArray[0] = UInt8(256 - Int(dataArray[0]))
                    }
                }
            }
        }
        
        let magnitude = BigUInt.init(Data.init(bytes: dataArray))
        
        self .init(sign: sign, magnitude: magnitude)
    }
}

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
        return serialize()
    }
}

extension Data: DataConvertible {
    
    public var asData: Data {
        return self
    }
}

func * <I>(lhs: I, rhs: I?) -> I? where I: BinaryInteger {
    guard let rhs = rhs else {
        return nil
    }
    return lhs * rhs
}

public enum ConcatMode {
    case prepend
    case append
}

extension String {
    func append(character: Character, toLength expectedLength: Int?) -> String {
        return prependingOrAppending(character: character, toLength: expectedLength, mode: .append)
    }
    
    func prepending(character: Character, toLength expectedLength: Int?) -> String {
        return prependingOrAppending(character: character, toLength: expectedLength, mode: .prepend)
    }
    
    mutating func prependOrAppend(character: Character, toLength expectedLength: Int?, mode: ConcatMode) {
        self = prependingOrAppending(character: character, toLength: expectedLength, mode: mode)
    }
    
    func prependingOrAppending(character: Character, toLength expectedLength: Int?, mode: ConcatMode) -> String {
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
