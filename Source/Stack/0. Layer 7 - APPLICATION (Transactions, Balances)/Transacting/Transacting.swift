//
//  Transacting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol Magical {
    var magic: Magic { get }
}

/// Type that is can make transactions of different types between Radix accounts
public protocol Transacting {
    func transfer(tokens: TransferTokenAction) -> CompletableWanted
}

// MARK: - Transacting + Accounting + NodeInteracting => Default Impl

// swiftlint:disable opening_brace

public extension Transacting
where
    Self: IdentityHolder,
    Self: AccountBalancing,
    Self: NodeInteractingSubmit,
    Self: Magical,
    Self: AtomSigning
{
    // swiftlint:enable opening_brace
    
    func transfer(tokens transferTokenAction: TransferTokenAction) -> CompletableWanted {
        
        log.info("\(transferTokenAction.sender.address) sends \(transferTokenAction.amount) of \(transferTokenAction.tokenResourceIdentifier) to \(transferTokenAction.recipient.address)")
        
        let actionToParticleGroupsMapper = DefaultTransferTokenActionToParticleGroupsMapper()
        
        let rri = transferTokenAction.tokenResourceIdentifier
        let powWorker = ProofOfWorkWorker()
        return getBalances(for: transferTokenAction.sender, ofToken: rri)
            .take(1)
            .map { $0.balance }
            .map { balance -> ParticleGroups in
                try actionToParticleGroupsMapper.particleGroups(for: transferTokenAction, currentBalance: balance)
            }.map { particleGroups -> Atom in
                particleGroups.wrapInAtom()
            }.flatMapLatest { atom -> Observable<ProofOfWorkedAtom> in
                powWorker.work(atom: atom, magic: self.magic).map {
                    try ProofOfWorkedAtom(atomWithoutPow: atom, proofOfWork: $0)
                }
            }.map { proofOfWorkAtom -> UnsignedAtom in
                try UnsignedAtom(atomWithPow: proofOfWorkAtom)
            }.map { unsignedAtom -> SignedAtom in
                try self.sign(atom: unsignedAtom)
            }.flatMapLatest { (signedAtom: SignedAtom) -> CompletableWanted in
                self.nodeSubmitter.submit(atom: signedAtom)
        }
    }
}
