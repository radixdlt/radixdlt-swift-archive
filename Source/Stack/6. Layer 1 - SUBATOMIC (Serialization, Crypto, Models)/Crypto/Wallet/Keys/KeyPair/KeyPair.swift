//
//  KeyPair.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// Holds an EC private key and public key
public struct KeyPair:
    PublicKeyOwner,
    Signing,
    Hashable
{
    // swiftlint:enable colon opening_brace

    public let privateKey: PrivateKey
    public let publicKey: PublicKey
    
    public init(private privateKey: PrivateKey, public publicKey: PublicKey) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}

// MARK: - Convenience
public extension KeyPair {
    init(private privateKey: PrivateKey) {
        self.init(private: privateKey, public: PublicKey(private: privateKey))
    }
    
    init() {
        self.init(private: PrivateKey())
    }
}

// MARK: - Public
public extension KeyPair {
    func encryptPrivateKey(withPublicKey publicKeyUsedToEncrypt: PublicKey) throws -> EncryptedPrivateKey {
        let encryptedPrivateKeyData = try publicKeyUsedToEncrypt.encrypt(privateKey.asData)
        return EncryptedPrivateKey(data: encryptedPrivateKeyData)
    }
}

// MARK: - Equtable
public extension PublicKeyOwner {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.publicKey == rhs.publicKey
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(publicKey)
    }
}
