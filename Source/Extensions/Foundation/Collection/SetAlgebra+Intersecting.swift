//
//  SetAlgebra+Intersecting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension SetAlgebra {
    func isIntersecting(_ other: Self) -> Bool {
        return !isDisjoint(with: other)
    }
}
