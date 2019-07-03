//
//  PoWSignSubmitAtom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-03.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//public extension NodeInteractingSubmit
//where
//    Self: AtomSigning,
//    Self: Magical
//{
//
//
//    func performProvableWorkThenSignAndSubmit(atom: Atom, powWorker: ProofOfWorkWorker) -> Completable {
//        
//        return powWorker.work(atom: atom, magic: self.magic)
//            .map { pow -> AtomWithFee in
//                try AtomWithFee(atomWithoutPow: atom, proofOfWork: pow)
//            }.map { proofOfWorkAtom -> UnsignedAtom in
//                try UnsignedAtom(atomWithPow: proofOfWorkAtom)
//            }.map { unsignedAtom -> SignedAtom in
//                try self.sign(atom: unsignedAtom)
//            }.flatMapLatest {
//                self.nodeSubmitter.submit(atom: $0)
//                
//        }
//    }
//}
