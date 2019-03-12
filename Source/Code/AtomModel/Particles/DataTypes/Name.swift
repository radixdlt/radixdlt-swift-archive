//
//  Name.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Name: PrefixedJsonCodable, CBORStringConvertible, MinLengthSpecifying, MaxLengthSpecifying {
    
    public static let minLength = 2
    public static let maxLength = 64
    
    public let value: String
    
    public init(validated unvalidated: String) {
        do {
            self.value = try Name.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension Name {
    var description: String {
        return value.description
    }
}
