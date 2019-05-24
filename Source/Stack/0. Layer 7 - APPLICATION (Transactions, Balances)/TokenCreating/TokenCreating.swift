//
//  TokenCreating.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol TokenCreating {
    /// Creates a token
    func create(token: CreateTokenAction) -> SingleWanted<ResourceIdentifier>
}

// swiftlint:disable opening_brace

public extension TokenCreating
where
    Self: NodeInteractingSubmit,
    Self: Magical,
    Self: AtomSigning
{
    // swiftlint:enable opening_brace
    func create(token createToken: CreateTokenAction) -> SingleWanted<ResourceIdentifier> {
        let actionToParticleGroupsMapper = DefaultCreateTokenActionToParticleGroupsMapper()
        
        let atom = actionToParticleGroupsMapper.particleGroups(for: createToken).wrapInAtom()
        
        let powWorker = ProofOfWorkWorker()
        
        // Prepare signed Atom
        let signedAtomObservable = powWorker.work(atom: atom, magic: self.magic)
            .map { pow -> ProofOfWorkedAtom in
                try ProofOfWorkedAtom(atomWithoutPow: atom, proofOfWork: pow)
            }.map { proofOfWorkAtom -> UnsignedAtom in
                try UnsignedAtom(atomWithPow: proofOfWorkAtom)
            }.map { unsignedAtom -> SignedAtom in
                try self.sign(atom: unsignedAtom)
            }
        
        // Submit atom
        return signedAtomObservable.flatMap { (signedAtom: SignedAtom) -> SingleWanted<ResourceIdentifier> in
            self.nodeSubmitter.submit(atom: signedAtom).asObservable().map { _ in
                return createToken.identifier
            }
        }
    }
}
