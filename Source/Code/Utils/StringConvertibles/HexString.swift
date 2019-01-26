//
//  HexString.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct HexString: DsonConvertible, StringConvertible, CharacterSetSpecifying, StringConvertibleErrorOwner, DataConvertible {
    
    public enum Error: StringConvertibleError {
        public static var invalidCharactersError: Error {
            return Error.invalidCharacters
        }
        
        case invalidCharacters
    }
    public static var allowedCharacters = CharacterSet.hexadecimal
    
    public let value: String
    public init(validated unvalidated: String) {
        do {
            self.value = try HexString.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
    
    public init(data: Data) {
        self.init(validated: data.toHexString())
    }
}

// MARK: - DataConvertible
public extension HexString {
    var asData: Data {
        return Data(hex: value)
    }
}
