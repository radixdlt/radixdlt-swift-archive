//
//  BigInt+BigUInt+BigInteger.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BigInt

public protocol BigInteger: BinaryInteger, DataConvertible, DataInitializable {
    func serialize() -> Data
}

// MARK: - DataConvertible
public extension BigInteger {
    var asData: Data {
        return serialize()
    }
}

public typealias BigSignedInt = BigInt
public typealias BigUnsignedInt = BigUInt
extension BigSignedInt: BigInteger {}
extension BigUnsignedInt: BigInteger {
    public init(data: Data) {
        self.init(data)
    }
}

public extension BigInt {
    
    /// Stolen from: https://github.com/attaswift/BigInt/issues/54
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
        
        return Data(array)
    }
    
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
        
        let magnitude = dataArray.unsignedBigInteger
        
        self .init(sign: sign, magnitude: magnitude)
    }
}

// MARK: - BigUnsignedInt + StringInitializable
extension BigUnsignedInt: StringInitializable {
    
    public init(string: String) throws {
        guard let fromString = BigUnsignedInt(string, radix: 10) else {
            throw InvalidStringError.invalidCharacters(expectedCharacters: CharacterSet.decimalDigits, butGot: string)
        }
        self = fromString
    }
}

// MARK: - BigUnsignedInt + StringRepresentable
extension BigUnsignedInt: StringRepresentable {
    public var stringValue: String {
        return self.toDecimalString()
    }
}

// MARK: - BigSignedInt + StringInitializable
extension BigSignedInt: StringInitializable {
    
    public init(string: String) throws {
        guard let fromString = BigSignedInt(string, radix: 10) else {
            throw InvalidStringError.invalidCharacters(expectedCharacters: CharacterSet.decimalDigits, butGot: string)
        }
        self = fromString
    }
}

// MARK: - BigSignedInt + StringRepresentable
extension BigSignedInt: StringRepresentable {
    public var stringValue: String {
        return self.toDecimalString()
    }
}
