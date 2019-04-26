//
//  DecodingError+Equatable.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension DecodingError: Equatable {
    
    public static func == (lhs: DecodingError, rhs: DecodingError) -> Bool {
        
        switch (lhs, rhs) {
            /// An indication that a value of the given type could not be decoded because
            /// it did not match the type of what was found in the encoded payload.
            /// As associated values, this case contains the attempted type and context
        /// for debugging.
        case (
            .typeMismatch(let lhsType, let lhsContext),
            .typeMismatch(let rhsType, let rhsContext)):
            return lhsType == rhsType && lhsContext == rhsContext
            
            /// An indication that a non-optional value of the given type was expected,
            /// but a null value was found.
            /// As associated values, this case contains the attempted type and context
        /// for debugging.
        case (
            .valueNotFound(let lhsType, let lhsContext),
            .valueNotFound(let rhsType, let rhsContext)):
            return lhsType == rhsType && lhsContext == rhsContext
            
            /// An indication that a keyed decoding container was asked for an entry for
            /// the given key, but did not contain one.
            /// As associated values, this case contains the attempted key and context
        /// for debugging.
        case (
            .keyNotFound(let lhsKey, _),
            .keyNotFound(let rhsKey, _)):
            return lhsKey.stringValue == rhsKey.stringValue
            
            /// An indication that the data is corrupted or otherwise invalid.
        /// As an associated value, this case contains the context for debugging.
        case (
            .dataCorrupted(let lhsContext),
            .dataCorrupted(let rhsContext)):
            return lhsContext == rhsContext
            
        default: return false
        }
    }
}

extension DecodingError.Context: Equatable {
    public static func == (lhs: DecodingError.Context, rhs: DecodingError.Context) -> Bool {
        return lhs.debugDescription == rhs.debugDescription
    }
}
