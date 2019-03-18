//
//  Date+ExpressibleByStringLiteral.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension Date: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        guard let date = TimeConverter.dateFrom(string: value) else {
            incorrectImplementation("invalid date string: '\(value)'")
        }
        self = date
    }
}
