//
//  AtomModelDecodingError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomModelDecodingError: Swift.Error, Equatable {
    case jsonDecodingErrorTypeMismatch(expectedSerializer: RadixModelType, butGot: RadixModelType)
    case noSerializer(in: JSON)
    case unknownSerializer(got: String)
}

// MARK: Equatable
public extension AtomModelDecodingError {
    static func == (lhs: AtomModelDecodingError, rhs: AtomModelDecodingError) -> Bool {
        switch (lhs, rhs) {
        case (
            .jsonDecodingErrorTypeMismatch(let lhsExpected, let lhsGot),
            .jsonDecodingErrorTypeMismatch(let rhsExpected, let rhsGot)):
            return lhsExpected == rhsExpected && lhsGot == rhsGot
        case (.noSerializer, noSerializer): return true
        case (.unknownSerializer, .unknownSerializer): return true
        default: return false
        }
    }
}
