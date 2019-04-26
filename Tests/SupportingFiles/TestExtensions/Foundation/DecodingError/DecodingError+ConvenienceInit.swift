//
//  DecodingError+ConvenienceInit.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension DecodingError {
    
    static var expectedStringButGotDictionary: DecodingError {
        return DecodingError.expectedType(String.self, "Expected to decode String but found a dictionary instead.")
    }
    
    static func keyNotFound<C>(_ key: C) -> DecodingError where C: CodingKey {
        let ignoredContext = DecodingError.Context(codingPath: [], debugDescription: "")
        return DecodingError.keyNotFound(key, ignoredContext)
    }
    
    static func expectedType<T>(_ type: T.Type, _ description: String) -> DecodingError {
        return DecodingError.typeMismatch(type, DecodingError.Context(codingPath: [], debugDescription: description))
    }
    
    static var invalidJSON: DecodingError {
        return DecodingError.dataCorrupted(description: "The given data was not valid JSON.")
    }
    
    static func dataCorrupted(description: String) -> DecodingError {
        return DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: description))
    }
}
