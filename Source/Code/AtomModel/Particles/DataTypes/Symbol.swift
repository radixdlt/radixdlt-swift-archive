//
//  Symbol.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Symbol: DsonDecodable, StringConvertible, CharacterSetSpecifying, MinLengthSpecifying, MaxLengthSpecifying {
    
    public static let minLength = 1
    public static let maxLength = 16
    public static let allowedCharacters = CharacterSet.numbersAndUppercaseAtoZ
    
    public let value: String
    
    public init(validated unvalidated: String) {
        do {
            self.value = try Symbol.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension Symbol {
    var description: String {
        return value.description
    }
}
