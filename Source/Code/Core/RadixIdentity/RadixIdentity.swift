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

// MARK: - AtomSigning
public extension RadixIdentity {
    func sign(atom unsignedAtom: UnsignedAtom) throws -> SignedAtom {
        let signatureId = owner.hashId
        let signature = try Signer.sign(unsignedAtom, privateKey: keyPair.privateKey)
        return unsignedAtom.signed(signature: signature, signatureId: signatureId)
    }
}

// MARK: - SignedAtomVerifier
public extension RadixIdentity {
    func didSign(atom: Atom) throws -> Bool {
        return try atom.signatures.containsSignature(for: atom, signedBy: self)
    }
}

// MARK: - Ownable
public extension RadixIdentity {
    var owner: PublicKey {
        return keyPair.publicKey
    }
}
