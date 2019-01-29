//
//  KeyPair.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct KeyPair {
    public let privateKey: PrivateKey
    public let publicKey: PublicKey
    
    public init(private privateKey: PrivateKey, public publicKey: PublicKey) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}

// MARK: - Convenience
public extension KeyPair {
    public init(private privateKey: PrivateKey) {
        self.init(private: privateKey, public: PublicKey(private: privateKey))
    }
}
