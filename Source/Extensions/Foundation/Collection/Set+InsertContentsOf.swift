//
//  Set+InsertContentsOf.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Set {
    mutating func insert<S>(contentsOf sequence: S) where S: Sequence, S.Element == Element {
        sequence.forEach {
            self.insert($0)
        }
    }
}
