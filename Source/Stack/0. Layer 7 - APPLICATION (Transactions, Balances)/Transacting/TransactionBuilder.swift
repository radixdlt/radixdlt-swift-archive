//
//  File.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class TransactionBuilder {

    private let universe: RadixUniverse

    public init(universe: RadixUniverse) {
        self.universe = universe
    }
}
