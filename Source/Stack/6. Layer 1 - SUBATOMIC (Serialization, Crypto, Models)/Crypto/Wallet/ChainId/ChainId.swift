//
//  ChainId.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

public enum ChainId {
    case testnet(Testnet)
    public enum Testnet {
        case winterfell
    }
}

// MARK: - To BitcoinKit
public extension ChainId {
    // BEFORE LAUNCH: Figure our own chain ids
    var bitcoinChainId: BitcoinKit.Network {
        return BitcoinKit.Network.testnetBTC
    }
}
