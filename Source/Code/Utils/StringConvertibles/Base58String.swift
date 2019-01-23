//
//  Base58String.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Base58String: StringConvertible, CharacterSetSpecifying, StringConvertibleErrorOwner {
    public enum Error: StringConvertibleError {
        public static var invalidCharactersError: Error {
            return Error.invalidCharacters
        }
        
        case invalidCharacters
    }
    
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
