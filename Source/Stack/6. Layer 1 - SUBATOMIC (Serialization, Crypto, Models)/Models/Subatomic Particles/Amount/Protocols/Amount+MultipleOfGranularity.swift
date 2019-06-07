//
//  Amount+MultipleOfGranularity.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-06.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Amount {
    func isExactMultipleOfGranularity(_ granularity: Granularity) -> Bool {
        let (_, remainder) = self.abs.magnitude.quotientAndRemainder(dividingBy: granularity.value.magnitude)
        return remainder == 0
    }
}
