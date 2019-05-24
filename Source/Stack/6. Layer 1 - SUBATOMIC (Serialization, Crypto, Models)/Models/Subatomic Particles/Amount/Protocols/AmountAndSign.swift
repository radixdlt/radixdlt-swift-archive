//
//  AmountAndSign.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AmountAndSign: CustomStringConvertible {
    case negative(BigUnsignedInt)
    case zero
    case positive(BigUnsignedInt)
}

// MARK: - CustomStringConvertible
public extension AmountAndSign {
    var description: String {
        switch self {
        case .negative(let negative): return "-\(negative)"
        case .positive(let positive): return "\(positive)"
        case .zero: return "0"
        }
    }
}
