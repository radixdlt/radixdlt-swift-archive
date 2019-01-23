//
//  HierarchicalDeterministicWallet.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

public struct HierarchicalDeterministicWallet {
    
    private let wrapped: BitcoinKit.HDWallet
    
    public init(seed: HierarchicalDeterministicMasterSeed, network: Network) {
        self.wrapped = BitcoinKit.HDWallet(seed: seed.data, network: network.bitcoinNetwork)
    }
}

// MARK: - Key Derivation
public extension HierarchicalDeterministicWallet {
    func keyPairFor(index: UInt32) throws -> KeyPair {
        let privateKey = PrivateKey(data: try wrapped.changePrivateKey(index: index).raw)
        return KeyPair(private: privateKey)
    }
}

// MARK: - Convenince Init
public extension HierarchicalDeterministicWallet {
    init(mnemonic: Mnemonic, network: Network) {
        let masterSeed = HierarchicalDeterministicMasterSeed(mnemonic: mnemonic)
        self.init(seed: masterSeed, network: network)
    }
}
