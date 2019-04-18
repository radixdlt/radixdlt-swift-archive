//
//  AtomModelDecodingError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomModelDecodingError: Swift.Error {
    case jsonDecodingErrorTypeMismatch(expectedSerializer: RadixModelType, butGot: RadixModelType)
    case noSerializer(in: JSON)
    case unknownSerializer(got: String)
}
