//
//  DataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import CryptoSwift

public protocol DataConvertible: CustomStringConvertible, LengthMeasurable {
    var asData: Data { get }
    var bytes: [Byte] { get }
    func toData(minByteCount: Int?, concatMode: ConcatMode) -> Data
}

// MARK: - Default Implementation
public extension DataConvertible {
    func toData(minByteCount expectedLength: Int? = nil, concatMode: ConcatMode = .prepend) -> Data {
      
        guard let expectedLength = expectedLength else {
            return self.asData
        }
        var modified: Data = self.asData
        let new = Byte(0x0)
        while modified.length < expectedLength {
            switch concatMode {
            case .prepend: modified = new + modified
            case .append: modified = modified + new
            }
        }
        return modified
        
    }

    var bytes: [Byte] {
        return asData.bytes
    }
}

// MARK: - LengthMeasurable
public extension DataConvertible {
    var length: Int {
        return asData.bytes.count
    }
}

// MARK: - Integer
public extension DataConvertible {
    var unsignedBigInteger: BigUnsignedInt {
        return BigUnsignedInt(asData)
    }
}

public enum StringConversionMode {
    case minimumLength(Int, ConcatMode)
    case trim
}

public extension Data {
    func toHexString(uppercased: Bool = false, mode: StringConversionMode? = nil) -> HexString {
        let hexString = HexString(data: asData)
        var hex = hexString.stringValue.uppercasedIfNeeded(uppercased)
        switch mode {
        case .none: break
        case .some(.minimumLength(let minimumLength, let concatMode)):
            hex.prependOrAppend(character: "0", toLength: minimumLength, mode: concatMode)
        case .some(.trim): hex.trim(character: "0")
        }
        
        return HexString(validated: hex)
    }
    
    func toBase64String(minLength: Int? = nil) -> Base64String {
        let data = toData(minByteCount: minLength, concatMode: .prepend)
        return Base64String(data: data)
    }
    
    func toBase58String(minLength: Int? = nil) -> Base58String {
        let data = toData(minByteCount: minLength, concatMode: .prepend)
        return Base58String(data: data)
    }
}

// MARK: - Base Conversion
public extension DataConvertible { 
    func toHexString(uppercased: Bool = false, mode: StringConversionMode? = nil) -> HexString {
        return asData.toHexString(uppercased: uppercased, mode: mode)
    }
    
    func toBase64String(minLength: Int? = nil) -> Base64String {
        return asData.toBase64String(minLength: minLength)
    }
    
    func toBase58String(minLength: Int? = nil) -> Base58String {
        return asData.toBase58String(minLength: minLength)
    }
    
    var hex: String {
        return toHexString().stringValue
    }
    
    var base58: String {
        return toBase58String().stringValue
    }
    
    var base64: String {
        return toBase64String().stringValue
    }
}

public extension String {
    func uppercasedIfNeeded(_ uppercase: Bool) -> String {
        guard uppercase else { return self }
        return uppercased()
    }
    
    public enum Direction {
        case leading, trailing
    }
    
    var reverse: String {
        return String(reversed())
    }
    
    mutating func trim(character toRemove: Character, caseInsensitive: Bool = false, direction: Direction = .leading) {
        self = trimming(character: toRemove, caseInsensitive: caseInsensitive, direction: direction)
    }
    
    func trimming(character toRemove: Character, caseInsensitive: Bool = false, direction: Direction = .leading) -> String {
        
        let dropIfNeeded = { (character: Character) -> Bool in
            guard caseInsensitive else {
                return character == toRemove
            }
            let uppercase = Character(String(toRemove).uppercased())
            let lowercase = Character(String(toRemove).lowercased())
            return character == uppercase || character == lowercase
        }
        
        switch direction {
        case .leading: return String(drop(while: { dropIfNeeded($0) }))
        case .trailing:
            return reverse.trimming(character: toRemove, direction: .leading).reverse
        }
    }
}

//public extension HexString {
//
//}

//public extension Base64String {
//    func toBase64String() -> Base64String {
//        return self
//    }
//}
//
//public extension Base58String {
//    func toBase58String() -> Base58String {
//        return self
//    }
//}

func + (lhs: DataConvertible, rhs: Byte) -> Data {
    return Data(bytes: lhs.bytes + [rhs])
}

func + (lhs: Byte, rhs: DataConvertible) -> Data {
    return Data(bytes: [lhs] + rhs.bytes)
}

// MARK: - Conformance
extension Array: DataConvertible where Element == Byte {
    public var asData: Data {
        return Data(bytes: self)
    }
}
