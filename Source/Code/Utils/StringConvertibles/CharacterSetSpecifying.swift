//
//  CharacterSetSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol CharacterSetSpecifying {
    static var allowedCharacters: CharacterSet { get }
}

public extension CharacterSetSpecifying {
    var allowedCharacters: CharacterSet {
        return Self.allowedCharacters
    }
    
    func isSupersetOfCharacters(in string: String) -> Bool {
        return allowedCharacters.isSuperset(of: CharacterSet(charactersIn: string))
    }
    
    func disallowedCharacters(in string: String) -> String? {
        let disallowed = CharacterSet(charactersIn: string).subtracting(allowedCharacters)
        guard !disallowed.isEmpty else {
            return nil
        }
        return disallowed.description
    }
    
    func validate(_ string: String) throws {
        if let disallowed = disallowedCharacters(in: string) {
            throw InvalidStringError.invalidCharacters(expectedCharacters: allowedCharacters.description, butGot: disallowed)
        }
    }
}
