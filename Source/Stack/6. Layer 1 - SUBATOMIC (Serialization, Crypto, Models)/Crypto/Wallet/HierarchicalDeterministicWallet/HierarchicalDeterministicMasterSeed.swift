//
//  HierarchicalDeterministicMasterSeed.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

public struct HierarchicalDeterministicMasterSeed {
    internal let data: Data
    
    public init(data: Data) {
        self.data = data
    }
}

// MARK: - From BitcoinKit
public extension HierarchicalDeterministicMasterSeed {
    init(mnemonic: Mnemonic) {
        self.init(data: mnemonic.seed)
    }
}
