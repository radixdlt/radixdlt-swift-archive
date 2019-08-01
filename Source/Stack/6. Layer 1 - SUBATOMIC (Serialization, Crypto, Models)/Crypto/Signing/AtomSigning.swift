//
//  AtomSigning.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomSigning {
    func sign(atom unsignedAtom: UnsignedAtom) throws -> Single<SignedAtom>
}

// MARK: - Default Implementation
public extension AtomSigning where Self: SigningRequesting, Self: PublicKeyOwner {
    func sign(atom unsignedAtom: UnsignedAtom) throws -> Single<SignedAtom> {
        let signatureId = publicKey.hashEUID
        
        return privateKeyForSigning.map {
            try Signer.sign(unsignedAtom, privateKey: $0)
        }.map {
            unsignedAtom.signed(signature: $0, signatureId: signatureId)
        }
    }
}
