//
//  AmountAndSign.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AmountAndSign {
    case negative(BigUnsignedInt)
    case zero
    case positive(BigUnsignedInt)
}
