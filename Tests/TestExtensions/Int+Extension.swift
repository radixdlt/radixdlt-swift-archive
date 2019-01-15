//
//  Int+Extension.swift
//  RadixSDKTests
//
//  Created by Alexander Cyon on 2019-01-15.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension Int {
    func timesDo(_ execute: () -> Void) {
        for _ in 0..<self {
            execute()
        }
    }
}
