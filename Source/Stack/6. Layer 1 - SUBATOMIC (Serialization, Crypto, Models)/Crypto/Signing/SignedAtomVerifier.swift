//
//  SignedAtomVerifier.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol SignedAtomVerifier {
    func didSign(atom: SignedAtom) throws -> Bool
}

// MARK: - Default Implementation
public extension SignedAtomVerifier where Self: PublicKeyOwner {
    func didSign(atom: SignedAtom) throws -> Bool {
        return try SignatureVerifier.verifyThat(
            signature: atom.signature,
            didSign: atom,
            usingKey: self.publicKey
        )
    }
}
