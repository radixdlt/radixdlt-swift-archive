//
//  Transacting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

///// Type that is can make transactions of different types between Radix accounts
//public protocol Transacting {
//    func transfer(
//        tokens: TransferTokenAction,
//        ifNoSigningKeyPresent: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent
//    ) -> CompletableWanted
//}

// MARK: - Transacting + Accounting + NodeInteracting => Default Impl

//public extension Transacting
//where
//    Self: IdentityHolder,
//    Self: AccountBalancing,
//    Self: NodeInteractingSubmit,
//    Self: Magical,
//    Self: AtomSigning,
//    Self: ProofOfWorkWorking,
//    Self: TokensDefinitionsReferencing
//{
//
//    func transfer(
//        tokens transfer: TransferTokenAction,
//    ) -> CompletableWanted {
//
//        if let tokenDefinition = self.tokens.token(for: transfer.tokenResourceIdentifier) {
//            guard transfer.amount.isExactMultipleOfGranularity(tokenDefinition.granularity) else {
//                return CompletableWanted.error(TransferError.amountNotMultipleOfGranularity)
//            }
//        }
//
//        let actionToParticleGroupsMapper = DefaultTransferTokensActionToParticleGroupsMapper()
//
//        let rri = transfer.tokenResourceIdentifier
//
//        // Get latest Balance
//        return getBalances(for: transfer.sender, ofToken: rri)
//            .take(1).map { $0.balance }
//            // Action => ParticleGroups
//            .map { try actionToParticleGroupsMapper.particleGroups(for: transfer, currentBalance: $0) }
//            // ParticleGroups => Atom
//            .map { $0.wrapInAtom() }
//            // Atom => AtomWithFee => SignedAtom => Submit to Node
//            .flatMapLatest { self.performProvableWorkThenSignAndSubmit(atom: $0, powWorker: self.proofOfWorkWorker) }
//    }
//}
