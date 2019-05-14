//
//  Amount+AmountAndSign.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Amount {
    var amountAndSign: AmountAndSign {
        let amount = abs.magnitude
        switch sign {
        case .negative: return .negative(amount)
        case .positive: return .positive(amount)
        case .zero: return .zero
        }
    }
}
