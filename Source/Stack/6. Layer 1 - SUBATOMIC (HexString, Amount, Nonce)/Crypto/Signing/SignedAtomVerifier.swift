//
//  SignedAtomVerifier.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol SignedAtomVerifier {
    func didSign(atom: Atom) throws -> Bool
}

public extension SignedAtomVerifier {
    func didSign(atom: SignedAtom) throws -> Bool {
        return try didSign(atom: atom.atom)
    }
}

// MARK: - Default Implementation
public extension SignedAtomVerifier where Self: PublicKeyOwner {
    func didSign(atom: Atom) throws -> Bool {
        return try atom.signatures.containsSignature(for: atom, signedBy: self)
    }
}
