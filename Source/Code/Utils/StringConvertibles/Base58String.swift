//
//  Base58String.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable:next colon
public struct Base58String:
    PrefixedJsonCodable,
    StringConvertible,
    StringRepresentable,
    CharacterSetSpecifying,
    DataConvertible,
    DataInitializable {

    public static var allowedCharacters = CharacterSet.base58
    
    public let value: String
    public init(validated unvalidated: String) {
        do {
            self.value = try Base58String.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

public extension Base58String {
    static let jsonPrefix: JSONPrefix = .addressBase58
    var base58String: Base58String {
        return self
    }
}

public extension Data {
    public var length: Int {
        return bytes.count
    }
}

// MARK: - DataInitializable
public extension Base58String {
    
    // swiftlint:disable:next function_body_length
    init(data: Data) {
        let bytes = data.bytes
        var x = data.unsignedBigInteger
        let alphabet = String.base58Alphabet.data(using: .utf8)!
        let radix = BigUnsignedInt(alphabet.count)
        
        var answer = [UInt8]()
        answer.reserveCapacity(bytes.count)
        
        while x > 0 {
            let (quotient, modulus) = x.quotientAndRemainder(dividingBy: radix)
            answer.append(alphabet[Int(modulus)])
            x = quotient
        }
        
        let prefix = Array(bytes.prefix(while: {$0 == 0})).map { _ in alphabet[0] }
        answer.append(contentsOf: prefix)
        answer.reverse()
        
        guard let base58String = String(bytes: answer, encoding: .utf8) else {
            incorrectImplementation("Should always be able to create a Base58 string from data.")
        }
        self.init(validated: base58String)
    }
}

// MARK: DataConvertible
public extension Base58String {
    var asData: Data {
    
        let alphabet = String.base58Alphabet.data(using: .utf8)!
        let radix = BigUnsignedInt(alphabet.count)
        let byteString = [UInt8](value.utf8)
        
        var answer = BigUnsignedInt(0)
        var temp = BigUnsignedInt(1)
        for character in byteString.reversed() {
            guard let index = alphabet.index(of: character) else {
                incorrectImplementation("Should always be able to convert to data")
            }
            answer += temp * BigUnsignedInt(index)
            temp *= radix
        }
        return byteString.prefix(while: { $0 == alphabet[0] }) + answer.serialize()
    }
}

// MARK: - StringRepresentable
public extension Base58String {
    var stringValue: String {
        return value
    }
}
