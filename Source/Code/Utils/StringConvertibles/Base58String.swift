//
//  Base58String.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Base58String: PrefixedJsonDecodable, StringConvertible, CharacterSetSpecifying, DataConvertible {

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

// MARK: - PrefixedJsonDecodable
public extension Base58String {
    static let jsonPrefix: JSONPrefix = .addressBase58
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
