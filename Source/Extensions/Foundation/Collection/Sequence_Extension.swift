//
//  Sequence_Extension.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Sequence where Element: Hashable {
    var asSet: Set<Element> {
        return Set(self)
    }
}
