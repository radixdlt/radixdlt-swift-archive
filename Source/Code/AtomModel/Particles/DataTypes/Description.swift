//
//  Description.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Description: PrefixedJsonDecodable, StringConvertible, MinLengthSpecifying, MaxLengthSpecifying {
    
    public static let minLength = 8
    public static let maxLength = 200
    
    public let value: String
    
    public init(validated unvalidated: String) {
        do {
            self.value = try Description.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension Description {
    var description: String {
        return value.description
    }
}
