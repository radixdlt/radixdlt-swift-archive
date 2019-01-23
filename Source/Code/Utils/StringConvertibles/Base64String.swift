//
//  Base64String.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Base64String: StringConvertible {
    public let value: String
    
    public init(data: Data) {
        self.value = data.base64EncodedString()
    }
    
    public init(validated unvalidated: String) {
        do {
            self.value = try Base64String.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

public extension Base64String {
    public enum Error: Swift.Error {
        case invalidCharacters
    }
    
    public static func validate(_ string: String) throws -> String {
        guard Data(base64Encoded: string) != nil else {
            throw Error.invalidCharacters
        }
        return string // valid
    }
}
