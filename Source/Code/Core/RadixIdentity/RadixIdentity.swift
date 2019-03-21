//
//  RadixIdentity.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon
public struct RadixIdentity:
    AtomSigning,
    SignedAtomVerifier,
    Signing,
    Ownable {
    // swiftlint:enable colon
  
    private let keyPair: KeyPair
    
    public init(keyPair: KeyPair) {
        self.keyPair = keyPair
    }
}

public extension RadixIdentity {
    init(`private` privateKey: PrivateKey) {
        self.init(keyPair: KeyPair(private: privateKey))
    }
}

// MARK: - Ownable
public extension RadixIdentity {
    var publicKey: PublicKey {
        return keyPair.publicKey
    }
}

// MARK: - Signing
public extension RadixIdentity {
    var privateKey: PrivateKey {
        return keyPair.privateKey
    }
}
