//
//  Optional+Debug.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension Optional where Wrapped: CustomStringConvertible {
    func printIfPresent() {
        guard let value = self else { return }
        log.verbose(value)
    }
}
