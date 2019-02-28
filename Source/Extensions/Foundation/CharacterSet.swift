//
//  CharacterSet.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension String {
    static var base58Alphabet: String {
        return "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    }
    
    static var base64Alphabet: String {
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
    }
}

public extension CharacterSet {
    static var hexadecimal: CharacterSet {
        let afToAF = CharacterSet(charactersIn: "abcdefABCDEF")
        return CharacterSet.decimalDigits.union(afToAF)
    }
    
    static var base58: CharacterSet {
        return CharacterSet(charactersIn: .base58Alphabet)
    }
    
    static var numbersAndUppercaseAtoZ: CharacterSet {
        return CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    }
    
    static var base64: CharacterSet {
        return CharacterSet(charactersIn: .base64Alphabet)
    }
}
