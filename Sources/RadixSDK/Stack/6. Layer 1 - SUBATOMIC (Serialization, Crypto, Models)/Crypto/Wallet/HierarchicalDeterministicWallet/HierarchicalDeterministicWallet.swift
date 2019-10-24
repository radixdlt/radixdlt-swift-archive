//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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

// MARK: - Convenience Init
public extension HierarchicalDeterministicWallet {
    init(mnemonic: Mnemonic, network: ChainId) {
        let masterSeed = HierarchicalDeterministicMasterSeed(mnemonic: mnemonic)
        self.init(seed: masterSeed, network: network)
    }
}
