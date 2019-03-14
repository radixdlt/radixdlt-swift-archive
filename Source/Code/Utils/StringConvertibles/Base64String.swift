//
//  Base64String.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Base64String: PrefixedJsonCodable, StringConvertible, StringRepresentable, CBORDataConvertible, DataInitializable, RequiringThatLengthIsMultipleOfN, CharacterSetSpecifying {
    public static let jsonPrefix: JSONPrefix = .bytesBase64
    
    public static var lengthMultiple = 4
    public static var allowedCharacters =  CharacterSet.base64
    
    public let value: String
    public init(validated unvalidated: String) {
        do {
            self.value = try Base64String.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - DataInitializable
public extension Base64String {
    init(data: Data) {
        self.value = data.base64EncodedString()
    }
}

// MARK: - StringRepresentable
public extension Base64String {
    var stringValue: String {
        return value
    }
}

// MARK: - DataConvertible
public extension Base64String {
    var asData: Data {
        guard let data = Data(base64Encoded: value) else {
            incorrectImplementation("Should always be possible to create data from a validated Base64String")
        }
        return data
    }
}
