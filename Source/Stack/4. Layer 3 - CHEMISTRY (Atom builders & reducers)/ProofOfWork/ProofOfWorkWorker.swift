//
//  DefaultProofOfWorkWorker.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol ProofOfWorkWorker {
    func work(seed: Data, magic: Magic, numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros) -> Single<ProofOfWork>
}

// MARK: - Convenience
public extension ProofOfWorkWorker {
    func work(
        atom: Atom,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default
        ) -> Single<ProofOfWork> {
        
        return work(
            seed: atom.radixHash.asData,
            magic: magic,
            numberOfLeadingZeros: numberOfLeadingZeros
        )
    }
    
}

