//
//  DefaultProofOfWorkWorker.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-07.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultProofOfWorkWorker: ProofOfWorkWorker {
    private let dispatchQueue = DispatchQueue(label: "Radix.DefaultProofOfWorkWorker", qos: .userInitiated)
    private let defaultNumberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros
    public init(defaultNumberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default) {
        self.defaultNumberOfLeadingZeros = defaultNumberOfLeadingZeros
    }
    
    deinit {
        log.verbose("POW Worker deinit")
    }
}

public extension DefaultProofOfWorkWorker {
    static let expectedByteCountOfSeed = 32
    
    func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default
    ) -> Single<ProofOfWork> {
        return Single.create { [unowned self] single in
            var powDone = false
            self.dispatchQueue.async {
                log.verbose("POW started")
                DefaultProofOfWorkWorker.work(
                    seed: seed,
                    magic: magic,
                    numberOfLeadingZeros: numberOfLeadingZeros
                ) { resultOfWork in
                    switch resultOfWork {
                    case .failure(let error):
//                        observer.onError(error)
                        single(.error(error))
                    case .success(let pow):
                        powDone = true
                        log.verbose("POW done")
                        single(.success(pow))
                    }
                }
            }
            
            return Disposables.create {
                if !powDone {
                    log.warning("POW cancelled")
                }
            }
        }
    }
}

// MARK: - Private
internal extension DefaultProofOfWorkWorker {
    static func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros targetNumberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        done: ((Result<ProofOfWork, Error>) -> Void)
        ) {
        guard seed.length == DefaultProofOfWorkWorker.expectedByteCountOfSeed else {
            let error = ProofOfWork.Error.workInputIncorrectLengthOfSeed(expectedByteCountOf: DefaultProofOfWorkWorker.expectedByteCountOfSeed, butGot: seed.length)
            done(.failure(error))
            return
        }
        
        var nonce: Nonce = 0
        let base: Data = magic.toFourBigEndianBytes() + seed
        var radixHash: RadixHash!
        repeat {
            nonce += 1
            let unhashed = base + nonce.toEightBigEndianBytes()
            radixHash = RadixHash(unhashedData: unhashed)
        } while radixHash.numberOfLeadingZeroBits < targetNumberOfLeadingZeros.numberOfLeadingZeros
        
        let pow = ProofOfWork(seed: seed, targetNumberOfLeadingZeros: targetNumberOfLeadingZeros, magic: magic, nonce: nonce)
        done(.success(pow))
    }
}

extension DefaultProofOfWorkWorker: FeeMapper {}
public extension DefaultProofOfWorkWorker {
    func feeBasedOn(atom: Atom, universeConfig: UniverseConfig, key: PublicKey) -> Single<AtomWithFee> {
        return work(atom: atom, magic: universeConfig.magic, numberOfLeadingZeros: self.defaultNumberOfLeadingZeros).map {
            try AtomWithFee(atomWithoutPow: atom, proofOfWork: $0)
        }
    }
}
