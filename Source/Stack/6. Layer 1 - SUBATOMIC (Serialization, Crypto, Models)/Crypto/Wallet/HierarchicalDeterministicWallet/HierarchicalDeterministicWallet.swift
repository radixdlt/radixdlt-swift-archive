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
    
    public init(seed: HierarchicalDeterministicMasterSeed, network: ChainId) {
        self.wrapped = BitcoinKit.HDWallet(seed: seed.data, network: network.bitcoinChainId)
    }
}

// MARK: - Key Derivation
public extension HierarchicalDeterministicWallet {
    func keyPairFor(index: UInt32) throws -> KeyPair {
        let privateKey = try PrivateKey(data: try wrapped.changePrivateKey(index: index).data)
        return KeyPair(private: privateKey)
    }
}

// MARK: - Convenince Init
public extension HierarchicalDeterministicWallet {
    init(mnemonic: Mnemonic, network: ChainId) {
        let masterSeed = HierarchicalDeterministicMasterSeed(mnemonic: mnemonic)
        self.init(seed: masterSeed, network: network)
    }
}
